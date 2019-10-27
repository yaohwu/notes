---
title: Database Change Notification
date: 2018-02-03 16:30:00
tags: database
---

应用端对于数据变更通知是有着较多需求场景的，例如数据更新后的提醒、预警；web 端展现数据对于实时性的要求等。大部分产品对于数据库中数据变更信息的获取只能通过轮询的方式实现，轮询的时间间隔太短会有性能问题，太长会损害实时性。因此，考虑实现数据库中数据变更后主动向应用程序发送通知，针对不同的数据库都有哪些可用方案呢？

<!-- more -->

## Oracle Database

[database change notification](https://docs.oracle.com/cd/E11882_01/java.112/e16548/dbchgnf.htm#JJDBC28815)

### 适用范围

表级别的增、删或改通知，例如，针对数据库表 A 有变更通知， 那么 A 中发生的增、删或改 都会通知，不能具体到某个字段或者某条记录，需要在被通知端判断。

## MySQL

### UDF + Trigger

使用的是 MySQL 的用户自定义函数 [User-Defined Functions](https://dev.mysql.com/doc/refman/5.7/en/create-function-udf.html)；

``A user-defined function (UDF) is a way to extend MySQL with a new function that works like a native (built-in) MySQL function such as ABS() or CONCAT().``

``For the UDF mechanism to work, functions must be written in C or C++ (or another language that can use C calling conventions), your operating system must support dynamic loading and you must have compiled mysqld dynamically (not statically).``

UDF 是一种 MySQL 扩展，自定义一个类似原生内置的函数，可以被同样使用。为了能达到这样的效果，这种函数必须使用能被 C 语言调用的语言编写，并且编译成动态链接库。Linux 上是 .so 文件，Windows 上是 .dll 文件。

我们使用这个 [mysql-udf-http](https://github.com/y-ken/mysql-udf-http) 来实现发送通知的效果，一个开源项目，8年多没人维护了。这是中文说明 [使用说明](http://zyan.cc/mysql-udf-http/)。

我在 Ubuntu 上安装的 MySQL ，再编译这个东西 是可以成功使用的。Windows 上没有尝试，应该也可以，只不过编译起来稍微麻烦一些。

MySQL 的触发器 [create-trigger](https://dev.mysql.com/doc/refman/5.7/en/create-trigger.html) 可以在 数据的增、删、改前后触发 trigger_body 的执行，可以执行多条 SQL 语句。

例如：

```java
//创建Trigger
String createTrigger =
        "CREATE TRIGGER test_update AFTER UPDATE ON `user` FOR EACH ROW " +
                "BEGIN " +
                "SET @tt_res = ( SELECT http_get ( 'http://192.168.1.123:8099/WebReport/ReportServer?op=notification&cmd=update' ) ); " +
                "END ";
```

其实就是触发器触发一下我们自定义的函数，向指定的接口发送一个请求，通知到应用层面数据被修改、新增、删除。

#### UDF+Trigger 适用范围

触发器针对的是表，每一行的变动都能被检测到；不能只监测指定字段的变动。
针对不同的平台，linux、windows 需要分别编译动态链接库，复制到MySQL插件文件夹下。
需要创建函数，创建触发器的权限。
如果数据变更非常频繁，那么会向指定的接口发送很多的请求，不知道web服务会不会挂。
触发器尽量简单只有一个，防止对数据库性能产生过多的影响。

表级别的增、删或改通知，例如，针对数据库表 A 有变更通知， 那么 A 中发生的增、删或改 都会通知，不能具体到某个字段或者某条记录，需要在被通知端判断。

### binlog

#### 原理

[MySQL binlog 增量数据解析服务](https://www.jianshu.com/p/be3f62d4dce0)

数据库为了主从复制结构和容灾，都会有一份提交日志 (commit log)，通过解析这份日志，理论上说可以获取到每次数据库的数据更新操作。

以下皆以 MySQL 为例：

两种方式获取 MySQL bin-log 的方式：

1. 如果是同一台主机，那么直接使用获取本地文件即可解析；
2. 如果是远程，那么可以通过 MySQL master 和 slave 的结构，伪装成一个 slave 来获取 master 的 bin-log 来解析。

上面那篇文章介绍的比较复杂，是关于集群数据同步的解决方案，我们不需要那么复杂，只需要当数据发生变更时解析到变更通知到应用即可。

#### 协议解析方案

时至今日， 已经有很多大厂开源了自己的 MySQL binlog 解析方案，Java 语言可选的有：

1. [mysql-binlog-connector-java](https://github.com/shyiko/mysql-binlog-connector-java)
1. [Canal](https://github.com/alibaba/canal)
1. [Puma](https://github.com/dianping/puma)

想自己造轮子实现协议的，也可以参考 [MySQL 官方文档](https://dev.mysql.com/doc/internals/en/replication-protocol.html)

#### demo

一个使用 mysql-binlog-connector-java 的 demo。

* 修改 MySQL 配置 my.cnf（Linux）或者my.ini（Windows）

```bash
[mysqld]
       log-bin=mysql-bin   //[必须]启用二进制日志
       server-id=1      //[必须]服务器唯一ID，默认是1
```

为了防止权限混乱，一般都是建立一个单独用于复制的账户。

```bash
create user rep;
grant replication slave on *.* to rep identified by '123456';
```

需重启数据库服务。

* Tapping into MySQL replication stream

```java
BinaryLogClient client = new BinaryLogClient("192.168.1.123",
            3306,//端口
            "yaohwu",//数据库
            "yaohwu",//用户名
            "*******");//密码

    client.registerLifecycleListener(new BinaryLogClient.AbstractLifecycleListener() {
        @Override
        public void onConnect(BinaryLogClient client) {
            super.onConnect(client);
            System.out.println("connect success");
        }

        @Override
        public void onCommunicationFailure(BinaryLogClient client, Exception ex) {
            super.onCommunicationFailure(client, ex);
            System.out.println("communication failure");
        }

        @Override
        public void onEventDeserializationFailure(BinaryLogClient client, Exception ex) {
            super.onEventDeserializationFailure(client, ex);
            System.out.println("event deserialize failure");
        }

        @Override
        public void onDisconnect(BinaryLogClient client) {
            super.onDisconnect(client);
            System.out.println("disconnect success");
        }
    });

    client.registerEventListener(new BinaryLogClient.EventListener() {
        @Override
        public void onEvent(Event event) {
            System.out.println(event.getHeader().getEventType().name());
        }
    });
    try {
        client.connect();
    } catch (IOException e) {
        e.printStackTrace();
    }

}
```

```bash
connect success
二月 03, 2018 4:11:49 下午 com.github.shyiko.mysql.binlog.BinaryLogClient connect
信息: Connected to 192.168.1.123:3306 at mysql-bin.000001/1444 (sid:65535, cid:9)
Event{header=EventHeaderV4{timestamp=0, eventType=ROTATE, serverId=1, headerLength=19, dataLength=28, nextPosition=0, flags=32}, data=RotateEventData{binlogFilename='mysql-bin.000001', binlogPosition=1444}}
ROTATE
Event{header=EventHeaderV4{timestamp=1517626550000, eventType=FORMAT_DESCRIPTION, serverId=1, headerLength=19, dataLength=100, nextPosition=0, flags=0}, data=FormatDescriptionEventData{binlogVersion=4, serverVersion='5.7.20-log', headerLength=19}}
FORMAT_DESCRIPTION
Event{header=EventHeaderV4{timestamp=1517645538000, eventType=ANONYMOUS_GTID, serverId=1, headerLength=19, dataLength=46, nextPosition=1509, flags=0}, data=null}
ANONYMOUS_GTID
Event{header=EventHeaderV4{timestamp=1517645538000, eventType=QUERY, serverId=1, headerLength=19, dataLength=55, nextPosition=1583, flags=8}, data=QueryEventData{threadId=6, executionTime=0, errorCode=0, database='yaohwu', sql='BEGIN'}}
QUERY
Event{header=EventHeaderV4{timestamp=1517645538000, eventType=TABLE_MAP, serverId=1, headerLength=19, dataLength=44, nextPosition=1646, flags=0}, data=TableMapEventData{tableId=245, database='yaohwu', table='user', columnTypes=15, 15, 15, 15, 15, columnMetadata=765, 765, 765, 765, 765, columnNullability={2, 3, 4}}}
TABLE_MAP
Event{header=EventHeaderV4{timestamp=1517645538000, eventType=EXT_WRITE_ROWS, serverId=1, headerLength=19, dataLength=32, nextPosition=1697, flags=0}, data=WriteRowsEventData{tableId=245, includedColumns={0, 1, 2, 3, 4}, rows=[
[1, 1, 1, 1, 1]
]}}
EXT_WRITE_ROWS
Event{header=EventHeaderV4{timestamp=1517645538000, eventType=XID, serverId=1, headerLength=19, dataLength=12, nextPosition=1728, flags=0}, data=XidEventData{xid=88}}
XID
Event{header=EventHeaderV4{timestamp=1517645543000, eventType=ANONYMOUS_GTID, serverId=1, headerLength=19, dataLength=46, nextPosition=1793, flags=0}, data=null}
ANONYMOUS_GTID
Event{header=EventHeaderV4{timestamp=1517645543000, eventType=QUERY, serverId=1, headerLength=19, dataLength=55, nextPosition=1867, flags=8}, data=QueryEventData{threadId=6, executionTime=0, errorCode=0, database='yaohwu', sql='BEGIN'}}
QUERY
Event{header=EventHeaderV4{timestamp=1517645543000, eventType=TABLE_MAP, serverId=1, headerLength=19, dataLength=44, nextPosition=1930, flags=0}, data=TableMapEventData{tableId=245, database='yaohwu', table='user', columnTypes=15, 15, 15, 15, 15, columnMetadata=765, 765, 765, 765, 765, columnNullability={2, 3, 4}}}
TABLE_MAP
Event{header=EventHeaderV4{timestamp=1517645543000, eventType=EXT_DELETE_ROWS, serverId=1, headerLength=19, dataLength=32, nextPosition=1981, flags=0}, data=DeleteRowsEventData{tableId=245, includedColumns={0, 1, 2, 3, 4}, rows=[
[1, 1, 1, 1, 1]
]}}
EXT_DELETE_ROWS
Event{header=EventHeaderV4{timestamp=1517645543000, eventType=XID, serverId=1, headerLength=19, dataLength=12, nextPosition=2012, flags=0}, data=XidEventData{xid=91}}
XID
Event{header=EventHeaderV4{timestamp=1517645554000, eventType=ANONYMOUS_GTID, serverId=1, headerLength=19, dataLength=46, nextPosition=2077, flags=0}, data=null}
ANONYMOUS_GTID
Event{header=EventHeaderV4{timestamp=1517645554000, eventType=QUERY, serverId=1, headerLength=19, dataLength=55, nextPosition=2151, flags=8}, data=QueryEventData{threadId=6, executionTime=0, errorCode=0, database='yaohwu', sql='BEGIN'}}
QUERY
Event{header=EventHeaderV4{timestamp=1517645554000, eventType=TABLE_MAP, serverId=1, headerLength=19, dataLength=44, nextPosition=2214, flags=0}, data=TableMapEventData{tableId=245, database='yaohwu', table='user', columnTypes=15, 15, 15, 15, 15, columnMetadata=765, 765, 765, 765, 765, columnNullability={2, 3, 4}}}
TABLE_MAP
Event{header=EventHeaderV4{timestamp=1517645554000, eventType=EXT_UPDATE_ROWS, serverId=1, headerLength=19, dataLength=129, nextPosition=2362, flags=0}, data=UpdateRowsEventData{tableId=245, includedColumnsBeforeUpdate={0, 1, 2, 3, 4}, includedColumns={0, 1, 2, 3, 4}, rows=[
{before=[yaohwu, ......, 13771717626, Software Engineer, China], after=[yaohwu, ......, 13771717629, Software Engineer, China]}
]}}
EXT_UPDATE_ROWS
Event{header=EventHeaderV4{timestamp=1517645554000, eventType=XID, serverId=1, headerLength=19, dataLength=12, nextPosition=2393, flags=0}, data=XidEventData{xid=93}}
XID
communication failure
disconnect success
```

### Binlog 适用范围

1. 监控整个数据库，不针对单个表或者字段，需要自己在代码中判断；
2. 删除、修改、添加都能够监听到。
大部分数据库变更通知都是基于数据库同步服务的，因此最细的角度就是表级别，不能到具体的字段或者记录，需要在被同步端也就是被通知端自行判断。

## 扩展方案

[debezium](https://github.com/debezium/debezium)

## 其他参考

[MySql 主从复制及配置实现](https://my.oschina.net/guol/blog/100179)
