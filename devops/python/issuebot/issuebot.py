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
    __slots__ = ('__id', '__title', '__content', '__status')

    # Constructor
    def __init__(self, id, title, content, status):
        self.__id = id
        self.__title = title
        self.__content = content
        self.__status = status

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
        self._projectid = projectid
        self._config = config
        self._pool = pool
        self._logger = logging.getLogger(projectid)
        self._url = self._get_gitea_api_url()

    def _get_gitea_api_url(self):
        base = self._config['Gitea']['url'] 
        repo = self._config[self._projectid]['api']
        token = self._config['Gitea']['token']
        return  base + '/' + repo + '?token=' + token

    def gen_tasks(self):
        pass

    def _query(self, db):
        conn = self._pool.get_connection()
        pass
    def _ser(self):
        pass

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
    config.read(os.path.dirname(__file__) + '/' + 'issue.ini')

    host = config['Mysql']['host']
    port = int(config['Mysql']['port'])
    user = config['Mysql']['user']
    password = config['Mysql']['password']
    database = config['Mysql']['database']

    conn_str = {'host': host, 'port': port, 'user': user, 'password': password, 'database': database}
    pool = ConnectionPool(name='pool', **conn_str)


    project_counts = config['Organazations']['counts']

    with Pool(processes=project_counts) as process:
        pass
