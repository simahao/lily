# DataType

## Oracle

### Number

- NUMBER(p,s)

  - p:precision，p∈[1, 38]， 代表是精度，其中最高有效位是最左边的非零位，最低有效位是最右边的已知数字。
  - s:scale， s∈[-84, 127]，代表范围，从小数点到最低有效位的位数。范围可以为正数也可以为负数。为正数代表小数点右边的有效位数，包括最低有效位数。范围为负数代表小数点左边的有效位数，到最低有效位，但不包括最低有效位数。对于范围为负数，最低有效数字位于小数点的左侧，例如，NUMBER(10, -2)意味着四舍五入到百位。
  - NUMBER(p,s)，s>0，表示有效位最大为p，小数位最多为s，小数点右边s位置开始四舍五入，若s>p，小数点右侧至少有s-p个0填充（必须从小数点处开始并连续）。
  - number(p,s)，s<0，表示有效位最大为p+|s|，没有小数位，小数点左边s位置开始四舍五入，小数点到左侧s位，每一位均为0。

- NUMBER(p)

    代表固定精度的正数，相当于NUMBER(p, 0)

- NUMBER

    代表浮点型数字

| Actual Data | Specified As |     Stored As     |
| :---------: | :----------: | :---------------: |
|   123.89    |    NUMBER    |      123.89       |
|   123.89    |  NUMBER(3)   |        124        |
|   123.89    | NUMBER(3,2)  | exceeds precision |
|   123.89    | NUMBER(4,2)  | exceeds precision |
|   123.89    | NUMBER(5,2)  |      123.89       |
|   123.89    | NUMBER(6,1)  |       123.9       |
|   123.89    | NUMBER(6,-2) |        100        |
|   0.01234   | NUMBER(4,5)  |      0.01234      |
|   0.00012   | NUMBER(4,5)  |      0.00012      |
|  0.000127   | NUMBER(4,5)  |      0.00013      |
|  0.0000012  | NUMBER(2,7)  |     0.0000012     |
| 0.00000123  | NUMBER(2,7)  |     0.0000012     |
|  1.20E-04   | NUMBER(2,5)  |      0.00012      |
|  1.20E-05   | NUMBER(2,5)  |      0.00001      |

### VARCHAR2

- Length

  VARCHAR2数据类型是可变长度的字符串，最大长度为4000字节。如果init.ora参数max_string_size=standard（默认值），VARCHAR2的最大长度可以是4000字节。如果init.ora参数max_string_size=extended，VARCHAR2的最大长度可以是32767字节。

- BYTE Sementic/CHAR Sementic

    在创建表的语句中，默认为BYTE语义，也就是存放的数据为单字节，可以通过制定character语义改变默认行为```VARCHAR2(10 char)```。特别是在有中文英文混写的字段，或者单独存放中文的字段，通过CHAR语义可以方便的构建你想要的长度，从而避免字符集编码的计算，比如说GBK为2字节编码，UTF-8是3字节编码，建立数据库的时候指定的字符集不同，字段采用byte语义的时候，又要存储多字节字符，就可以通过CHAR语义解决。同样CHAR字段也适用此条规则。

    ```SQL
    create table test
    (
        id number,
        name varchar2(10)
    )
    insert into test(id, name) values(1, '1234567890');

    select length(name) len from test

    len
    ----
    10

    select substr(name, 1, 5) sub from test;

    sub
    -----
    12345

    alter table test modify name varchar2(10 char);

    insert into test(id, name) values(2, '开发二部开发二部ab');

    select length(name) len from test;

    len
    -----
    10
    10

    select substr(name, 1, 5) sub from test;

    sub
    ---------
    12345
    开发二部开
    ```

### NVARHAR2

N:National，也就是说这个字段会按照national字符集进行编码，如果将NVARCHAR2的变量赋值给VARCHAR2，oracle会将字符集从national字符集转化为DB的字符集

### CHAR

char类型是固定长度，最大长度为2000(byte or char)，如果插入的数据小于指定的size，oracle会填补blank。
