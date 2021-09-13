from timeit import default_timer

import pymysql


class MysqlUtils():

    def __init__(self, commit=True, log_time=True, log_label='total time'):
        self.__commit = commit
        self.__log_time = log_time
        self.__log_label = log_label

    def __set_connection(self, host, port, db_name, user_name, pwd):
        self.__host = host
        self.__port = port
        self.__db_name = db_name
        self.__user_name = user_name
        self.__pwd = pwd
    
    @property
    def cursor(self):
        return self.__cursor

    def __enter__(self):
        if self.__log_time == True:
            self.__start = default_timer()
        self.__conn = pymysql.connect(host=self.__host, port=self.__port, db_name=self.__db_name, user_name=self.__user_name, password=self.__pwd)
        self.__cursor = self.__conn.cursor(pymysql.cursor.DictCursor)
        self.__conn.autocommit = True

        pass

    def __exit__(self, *exec_args):
        pass
