import logging

from retry import retry

logging.basicConfig(level=logging.WARN, format='%(levelname)8s %(asctime)s: %(message)s', datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger(__name__)

@retry(tries=3, delay=3, jitter=1)
def test() -> int:
    print('retrying')
    ret = 10
    if ret <= 10:
        raise Exception("title={}, content={}".format("abcd", "defg"))
    return 10


if __name__ == "__main__":
    test()
