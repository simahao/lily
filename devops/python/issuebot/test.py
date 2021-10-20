import logging
import os
from configparser import ConfigParser

from retry import retry

logging.basicConfig(level=logging.WARN, format='%(levelname)8s %(asctime)s: %(message)s', datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)
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
@retry(tries=3, delay=3, jitter=1)
def test1() -> int:
    print('retrying')
    ret = 10
    if ret <= 10:
        raise Exception("title={}, content={}".format("abcd", "defg"))
    return 10

@retry(tries=3, delay=3, jitter=1)
def test2():
    try:
        print("retrying")
        a = 1 / 0
    except ZeroDivisionError:
        print("exception")
        raise Exception("new")
    return 10
def test3():
    print(test2())

def test4():
    issue1 = Issue(1, 't1', 'c1', '打开', '严重', '一般')
    issue2 = Issue(2, 't2', 'c2', '打开', '严重', '一般')
    res = (issue1, issue2)
    for e in res:
        print(e.id)
        print(e.title)
        print(e.content)
        print(e.status)

def test5():
    l1 = [('c','d'),('c','e'),('a','b'),('a', 'd')]
    l2 = [('a','c'),('b','d')]
    starters = set(x for x, _ in l2)

    x = [(x, y) for x, y in l1 if x not in starters] + l2
    print(x)

def test6():
    str1 = "1,2,3,4,5,6,7,8".split(sep=',')
    print(str1)
    tup = tuple(str1)
    print(tup)

def test7():
    conf = ConfigParser()
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Octopus')
    conf.read(filenames=path, encoding='utf8')
    try:
        ids = conf['db1']['id'].split(sep=',')
    except Exception:
        return []
    else:
        return ids

def test8():
    conf = ConfigParser()
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Octopus')
    conf.read(filenames=path, encoding='utf8')
    if conf.has_section('db4') is False:
        conf.add_section('db4')
    conf.set('db4', 'id2', '1,2,3,4')

    with open(path, 'w') as configfile:
        conf.write(configfile)

if __name__ == "__main__":
    test8()
