import json
import logging
import os
from configparser import ConfigParser
from multiprocessing import Pool

from pool import ConnectionPool
from requests import Request, Response, post
from retry import retry

logging.basicConfig(level=logging.WARN, format='%(levelname)8s %(asctime)s: %(message)s', datefmt='%m-%d %H:%M:%S')

class GiteaException(Exception):
    """gitea exception"""

class MysqlException(Exception):
    """mysql exception"""

class Issue:

    # bind four property
    __slots__ = ('__id', '__title', '__content', '__status', '__severity',  '__reason')

    # Constructor
    def __init__(self, id, title, content, status, severity, reason):
        self.__id = id
        self.__title = title
        self.__content = content
        self.__status = status
        self.__severity = severity
        self.__reason = reason

    @property
    def id(self):
        return self.__id

    @id.setter
    def id(self, id):
        self.__id = id

    @property
    def title(self):
        return self.__title

    @title.setter
    def title(self, title):
        self.__title = title

    @property
    def content(self):
        return self.__content

    @content.setter
    def content(self, content):
        self.__content = content

    @property
    def status(self):
        return self.__status

    @status.setter
    def status(self, status):
        self.__status = status

    @property
    def severity(self):
        return self.__severity

    @severity.setter
    def severity(self, severity):
        self.__severity = severity

    @property
    def reason(self):
        return self.__reason

    @reason.setter
    def reason(self, reason):
        self.__reason = reason

    # toString()
    def __str__(self):
        return "id:%d title:%s content:%s status:%s" % (self.__di, self.__title, self.__content, self.__status)

    # equals
    def __eq__(self, other):
        if (self.__id == other.id
            and self.__title == other.title
            and self.__content == other.content
            and self.__status == other.status):
            return True
        else:
            return False

class IssueBot():

    HEADER = {'content-type': 'application/json',
        'accept': 'application/json'}

    def __init__(self, projectid: str, config: ConfigParser, pool: ConnectionPool):
        # e.x. Octopus
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


    @retry(tries=10, delay=10, jitter=5)
    def gen_tasks(self) -> tuple:
        conn = self._pool.get_connection()
        dbs = self._config[self._projectid]['database'].split(',')
        status_list = self._config['Status']['status'].split(',')
        status_condition = ''
        for idx, status in enumerate(status_list):
            status_condition += "'{}'".format(status) if idx == 0 else ", '{}'".format(status)

        results = ()
        for db in dbs:
            ids = self._get_ids(dbname=db)
            sql = "select * from {}.test where status in ({})".format(db, status_condition)
            rows = conn.querydb(sql=sql)
            for row in rows:
                pass
        return results

    def _get_ids(self, dbname: str) -> list:
        self._project_db.read(filenames=self._project_path, encoding='utf8')
        return self._project_db[dbname]['id'].split(',')

    def _sync_ids(self, dbname: str, new_ids: str):
        self._project_db.read(filenames=self._project_path, encoding='utf8')
        if self._project_db.has_section(dbname) is False:
            self._project_db.add_section(dbname)
        self._project_db.set(dbname, 'id', new_ids)
        with open(self._project_path) as configfile:
            self._project_db.write(configfile)

    @retry(tries=10, delay=10, jitter=5)
    def _gen_issue(self, title: str, content: str) -> Response:
        data = {'title': title, 'body': content}
        res = post(url=self._url, data=data)
        if res.status_code != 200:
            raise GiteaException("call gitea api failed, title={}, content={}".format(title, content))
        return res

    def bot_work(self):
        pass

if __name__ == "__main__":
    config = ConfigParser()
    conf_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'issue.ini')
    config.read(filenames=conf_path, encoding='utf8')

    host = config['Mysql']['host']
    port = int(config['Mysql']['port'])
    user = config['Mysql']['user']
    password = config['Mysql']['password']
    # database = config['Mysql']['database']

    conn_str = {'host': host, 'port': port, 'user': user, 'password': password}
    pool = ConnectionPool(name='pool', **conn_str)


    project_counts = config['Organazations']['counts']

    bot = IssueBot(projectid='Octopus', config=config, pool=pool)
    bot.gen_tasks()
    # with Pool(processes=project_counts) as process:
    #     pass
