import logging
import queue
import threading

import pymysql

__all__ = ['Connection', 'ConnectionPool', 'logger']

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
        # pymysql.connections.Connection.__exit__(self, exc_type, exc_value, trace)
        if self._pool:
            if not exc_type:
                self._pool.return_connection(self)
            else:
                self._pool.return_connection(self._recreate(*self.args, **self.kwargs))
                self._pool = None
                try:
                    self.close()
                    logger.warning("close not reusable connection from pool(%s) caused by %s", self._pool.name, exc_value)
                except Exception:
                    pass

    def _recreate(self, *args, **kwargs):
        conn = Connection(*args, **kwargs)
        logger.debug('create new connection due to pool(%s) lack of resource', self._pool._name)
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

    def querydb(self, sql, args=None, dictcursor=False, return_one=False, exec_many=False):
        """
        :param str sql: Query to execute.
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
                    cur.executemany(sql, args)
                else:
                    cur.execute(sql, args)
            except Exception as e:
                logger.error("error type:{%s}, error message: {%s}", e.__class__.__name__, e)
            return cur.fetchone() if return_one else cur.fetchall()

    def updatedb(self, sql, args=None, exec_many=False):
        """
        :param str sql: update/insert to execute.
        :param args: parameters used with query. (optional)
        :type args: tuple, list or dict
        If args is a list or tuple, %s can be used as a placeholder in the query.
        If args is a dict, %(name)s can be used as a placeholder in the query.

        insert one record
        sql=" insert into USER values (%s,%s,%s,%s)"
        params=(张三，18，男，北京)

        insert multiply records
        sql=" insert into USER values (%s,%s,%s,%s)"
        params=[(张三，18，男，北京), (李四，19，女，北京)]
        """
        with self:
            cur = self.cursor()
            try:
                if exec_many:
                    cur.executemany(sql, args)
                else:
                    cur.execute(sql, args)
                self.commit()
            except Exception as e:
                logger.error("error type:{%s}, error message: {%s}", e.__class__.__name__, e)
                self.rollback()

class ConnectionPool:

    _HARD_LIMIT = 10
    _THREAD_LOCAL = threading.local()
    _THREAD_LOCAL.retry_counter = 0

    def __init__(self, size=5, name=None, *args, **kwargs):
        self._pool = queue.Queue(self._HARD_LIMIT)
        self._size = size if 0 < size < self._HARD_LIMIT else self._HARD_LIMIT
        self._name = name if name else '-'.join(
            [kwargs.get('host', 'localhost'), str(kwargs.get('port', 3306)),
             kwargs.get('user', ''), kwargs.get('database', '')])

        for _ in range(self._size):
            conn = Connection(*args, **kwargs)
            conn._pool = self
            self._pool.put(conn)

    def get_connection(self, timeout=1, retry=1):
        try:
            conn = self._pool.get(timeout=timeout) if timeout > 0 else self._pool.get_nowait()
            logger.debug("get connection from pool(%s)", self._name)
            return conn
        except queue.Empty:
            if not hasattr(self._THREAD_LOCAL, 'retry_counter'):
                self._THREAD_LOCAL.retry_counter = 0
            if retry > 0:
                self._THREAD_LOCAL.retry_counter += 1
                logger.debug("retry get connection from pool(%s), the %d times", self._name, self._THREAD_LOCAL.retry_counter)
                retry -= 1
                return self.get_connection(timeout, retry)
            else:
                total_times = self._THREAD_LOCAL.retry_counter + 1
                self._THREAD_LOCAL.retry_counter = 0
                raise GetConnectionFromPoolError("can't get connection from pool({}) within {}*{} second(s)".format(
                    self._name, timeout, total_times))

    def return_connection(self, conn):

        try:
            self._pool.put_nowait(conn)
            logger.debug("put connection back to pool(%s)", self._name)
        except queue.Full:
            logger.warning("put connection to pool(%s) error, pool is full, size:%d", self._name, self.size())

    def size(self):
        return self._pool.qsize()

class GetConnectionFromPoolError(Exception):
    """Exception related can't get connection from pool within timeout seconds."""


if __name__ == "__main__":
    #config = {'host': '172.27.234.197', 'port': 3306, 'user': 'root', 'password': 'root', 'database': 'mysql'}
    config = {'host': '192.168.128.128', 'port': 3306, 'user': 'gitea', 'password': 'gitea', 'database': 'gitea'}
    pool = ConnectionPool(name='pool', **config)
    conn = pool.get_connection()
    #result = conn.query("select * from sys_config")
    result = conn.querydb("select * from repository where id = {}".format(4))
    for row in result:
        print(row)

    conn = pool.get_connection()
    data = [('abc', 18), ('def', 19)]
    # data = ('abc', 18)
    conn.updatedb("insert into test values (%s, %s)", data, exec_many=True)
