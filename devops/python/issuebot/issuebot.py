import logging
import os
import threading
import time
from configparser import ConfigParser
from multiprocessing import Pool, Process

from pool import ConnectionPool
from requests import Response, post
from retry import retry

import applog
from issue import Issue

# logging.basicConfig(level=logging.WARN, format='%(levelname)8s %(asctime)s: %(message)s', datefmt='%m-%d %H:%M:%S')


class IssueBot():

    HEADER = {'content-type': 'application/json',
        'accept': 'application/json'}

    def __init__(self, projectid: str, config: ConfigParser, pool: ConnectionPool):
        self._projectid = projectid
        self._config = config
        self._pool = pool
        self._logger = logging.getLogger(projectid)
        self._url = self._get_gitea_api_url()
        # save issue id that has been sent to gitea
        self._project_db = ConfigParser()
        self._project_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), projectid)

    def _get_gitea_api_url(self) -> str:
        base = self._config['Gitea']['url']
        repo = self._config[self._projectid]['api']
        token = self._config['Gitea']['token']
        return  base + '/' + repo + '?token=' + token

    def do_task(self):
        self._logger.info("start task: {}".format(self._projectid))
        dbs = self._config[self._projectid]['database'].split(',')
        status_list = self._config['Status']['status'].split(',')
        status_condition = ''
        for idx, status in enumerate(status_list):
            status_condition += "'{}'".format(status) if idx == 0 else ", '{}'".format(status)

        while True:
            for db in dbs:
                ids = self._get_ids(dbname=db)
                sql = "select id,title,defect_description,status,severity,primary_reason,subsystem from {}.test where status in ({})".format(db, status_condition)
                conn = self._pool.get_connection()
                rows = conn.querydb(sql=sql)
                for row in rows:
                    # if this id has been handled, get next data
                    if str(row[0]) in ids:
                        continue
                    else:
                        # update id file and send gitea request
                        self._gen_issue(Issue(row[0], row[1], row[2], row[3], row[4], row[5], row[6]))
                        ids += [row[0]]
                        str_ids = [str(x) for x in ids]
                        sep = ','
                        self._sync_ids(dbname=db, new_ids=sep.join(str_ids))
            time.sleep(int(self._config['App']['Interval']))

    def _get_ids(self, dbname: str) -> list:
        """get id list by section->option->value from local file"""
        self._project_db.read(filenames=self._project_path, encoding='utf8')
        return self._project_db[dbname]['id'].split(',') if self._project_db.has_section(dbname) else []

    @retry(tries=10, delay=10, jitter=5)
    def _sync_ids(self, dbname: str, new_ids: str):
        self._project_db.read(filenames=self._project_path, encoding='utf8')
        # if section is not exist, add section firstly
        if self._project_db.has_section(dbname) is False:
            self._project_db.add_section(dbname)
        # update section->option->value
        self._project_db.set(dbname, 'id', new_ids)
        with open(self._project_path, 'w') as idfile:
            self._project_db.write(idfile)

    @retry(tries=10, delay=10, jitter=5)
    def _gen_issue(self, issue: Issue) -> Response:
        data = {'id': issue.id,
                'title': issue.title,
                'defect_desc': issue.defect_desc,
                'status': issue.status,
                'severity': issue.severity,
                'reason': issue.reason,
                'subsystem': issue.subsystem}
        return None
        # res = post(url=self._url, data=data, timeout=10)
        # if res.status_code != 200:
        #     raise GiteaException("call gitea api failed, id={}, title={}".format(issue.id, issue.title))
        # return res

class GiteaException(Exception):
    """gitea exception"""

class MysqlException(Exception):
    """mysql exception"""


class IssueThread(threading.Thread):
    def __init__(self, projectid: str, config: ConfigParser, pool: ConnectionPool):
        super().__init__()
        self._projectid = projectid
        self._config = config
        self._pool = pool
    def run(self):
        bot = IssueBot(projectid=self._projectid, config=self._config, pool=self._pool)
        bot.do_task()

def main():
    config = ConfigParser()
    conf_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'issuehome.ini')
    config.read(filenames=conf_path, encoding='utf8')
    host = config['Mysql']['host']
    port = int(config['Mysql']['port'])
    user = config['Mysql']['user']
    password = config['Mysql']['password']
    conn_str = {'host': host, 'port': port, 'user': user, 'password': password}
    pool = ConnectionPool(name='pool', **conn_str)
    project_counts = int(config['Organazations']['counts'])


    # bot = IssueBot()
    ts = []
    for i in range(project_counts):
        projectid = config['Organazations']['org' + str(i)]
        t = IssueThread(projectid=projectid, config=config, pool=pool)
        t.start()
        ts.append(t)

    for i in range(project_counts):
        ts[i].join()
    
if __name__ == "__main__":
    main()
