from timeit import default_timer

import pymysql
from dbutils.pooled_db import PooledDB


class Mysql():

    def __init__(self, host, port, db, user, password, log_time=True, log_label='total time'):
        self.__host = host
        self.__port = port
        self.__db = db
        self.__user = user
        self.__password = password
        self.__log_time = log_time
        self.__log_label = log_label

    def __enter__(self):
        if self.__log_time == True:
            self.__start = default_timer()
        self.__conn = pymysql.connect(host=self.__host, port=self.__port, database=self.__db, user=self.__user, password=self.__password)
        self.__cursor = self.__conn.cursor(pymysql.cursors.DictCursor)
        self.__conn.autocommit = False 
        return self

    def __exit__(self, *exec_args):
        if self.__conn.autocommit is False:
            self.__conn.commit()

        self.__cursor.close()
        self.__conn.close()

        if self.__log_time is True:
            diff = default_timer() - self.__start
            print('-- %s: %.6f s' % (self.__log_label, diff))

    @property
    def cursor(self):
        return self.__cursor

    def get_count(self, sql, params=None, count_key='count(*)'):
        self.cursor.execute(sql, params)
        data = self.cursor.fetchone()
        if not data:
            return 0
        return data[count_key]

    def fetch_one(self, sql, params=None):
        self.cursor.execute(sql, params)
        return self.cursor.fetchone()

    def fetch_all(self, sql, params=None):
        self.cursor.execute(sql, params)
        return self.cursor.fetchall()

    def fetch_by_pk(self, sql, pk):
        self.cursor.execute(sql, (pk,))
        return self.cursor.fetchall()

    def update_by_pk(self, sql, params=None):
        self.cursor.execute(sql, params)

if __name__ == '__main__':
    with Mysql('192.168.128.128', 3306, 'gitea', 'gitea', 'gitea') as mysql:
        mysql.cursor.execute("select count(*) as total from repository")
        data = mysql.cursor.fetchone()
        print(data)
