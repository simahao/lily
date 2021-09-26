import logging
import queue

import pymysql

logging.basicConfig(level=logging.DEBUG, format='%(levelname)8s %(asctime)s: %(message)s', datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)
#logger.setLevel('WARNING')


class Connection(pymysql.connections.Connection):

    _pool = None

    def __init__(self, *args, **kwargs):
        pymysql.connections.Connection.__init__(self, *args, **kwargs)
        self.args = args
        self.kwargs = kwargs

    def __exit__(self, exc_type, exc_value, trace):
        pymysql.connections.Connection.__exit__(self, exc_type, exc_value, trace) 
        if self._pool:
            if not exc_type:
                self._pool.return_connection(self)
            else:
                self._pool.return_connection(self, self._recreate(*self.args, **self.kwargs))
                self._pool = None
                try:
                    self.close()
                    logger.warning("close not reusable connection from pool(%s) caused by %s", self._pool.name, exc_value)
                except Exception:
                    pass

    def _recreate(self, *args, **kwargs):
        conn = Connection(*args, **kwargs)
        logger.debug('create new connection due to pool(%s) lack of resource', self._pool.name)
        return conn

    def close(self):
        """overwritten
        with pool: return connection back to pool
        without pool: close this connection quietly
        """

        if self._pool:
            self._pool.return_connection(self)
        else:
            pymysql.connections.Connection.close(self)

    def query(self, query, args=None, dictcursor=False, return_one=False, exec_many=False):
        """
        :param str query: Query to execute.
        :param args: parameters used with query. (optional)
        :type args: tuple, list or dict
        :return: Number of affected rows
        :rtype: int

        dictcursor: whether want use the dict cursor(cursor's default type is tuple)
        return_one: whether want only one row of the result
        exec_many: batch mode

        If args is a list or tuple, %s can be used as a placeholder in the query.
        If args is a dict, %(name)s can be used as a placeholder in the query.
        """
        with self:
            cur = self.cursor() if dictcursor is False else self.cursor(pymysql.cursors.DictCursor)
            try:
                if exec_many:
                    cur.execute_many(query, args)
                else:
                    cur.execute(query, args)
            except Exception:
                raise
            return cur.fetchone() if return_one else cur.fetchall()


class ConnectionPool:

    def __init__(self, *args, **kwargs):
        pass

    def get_connection(self, timeout=1, retry=5):
        pass 

    def return_connection(self, conn):
        pass
