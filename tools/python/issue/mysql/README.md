# example

## use connection

```python
    config = {'host': '192.168.128.128', 'port': 3306, 'user': 'gitea', 'password': 'gitea', 'database': 'gitea'}
    conn = Connection(**config)
    result = conn.querydb("select * from repository where id = {}".format(4))
    for row in result:
        print(row)
```

## use connection pool

```python
    config = {'host': '192.168.128.128', 'port': 3306, 'user': 'gitea', 'password': 'gitea', 'database': 'gitea'}
    pool = ConnectionPool(name='pool', **config)
    conn = pool.get_connection()
    result = conn.querydb("select * from repository where id = {}".format(4))
    for row in result:
        print(row)
```
