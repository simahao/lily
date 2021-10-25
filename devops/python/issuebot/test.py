import logging
import os
from configparser import ConfigParser

from retry import retry

logging.basicConfig(level=logging.WARN, format='%(levelname)8s %(asctime)s: %(message)s', datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)
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


def test5():
    l1 = [('c','d'),('c','e'),('a','b'),('a', 'd')]
    l2 = [('a','c'),('b','d')]
    starters = set(x for x, _ in l2)

    x = [(x, y) for x, y in l1 if x not in starters] + l2
    print(x)

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
    pass
