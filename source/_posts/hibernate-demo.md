---
title: hibernate demo
date: 2018-05-01 23:44:14
tags: [orm,database,hibernate]
---

最近在做远程设计，因为涉及到权限部分，所以看了看决策平台的代码，发现数据库操作都是用 hibernate，很成熟的技术了，但是我们之前的开发中可能用的很少，恰好之后可能会用，因此就炒炒冷饭，分享下这个，顺便理一下决策平台是怎么使用 hibernate 的。

<!-- more -->

## ORM

对于 ORM(Object-Relational Mapping) 对象关系映射，相信大家或多或少都用过 ORM 的框架。

>面向对象是从软件工程基本原则（如耦合、聚合、封装）的基础上发展起来的，而关系数据库则是从数学理论发展而来的，两套理论存在显著的区别。为了解决这个不匹配的现象，对象关系映射技术应运而生。

是将面向关系概念转化成面向对象概念的一种思想。

| 面向对象概念 | 面向关系概念 |
| :----------: | :----------: |
| 类           | 表           |
| 对象         | 行(记录)     |
| 属性         | 列(字段)     |

将 **关系数据库** 中表中的 **记录** 映射成为 **对象**，以对象的形式展现，可以将对数据库的操作转化为对对象的操作。

可以方便开发人员以面向对象的思想来实现对数据库的操作。

从思想上来说，当然是很方便，同一种面向对象的思想，简单不过弯子。但是从代码上来说，这个方便不方便也是看场景的。简单的demo 当然还是直接写 sql 更快。

### java的一些 ORM 框架

Hibernate,MyBatis 等。

稍后我们对这两个框架做一下对比。

## Hibernate ORM

[wikipedia 地址](https://zh.wikipedia.org/wiki/Hibernate)

### demo

我们先通过一个 demo 来了解一下 hibernate ORM。

搭环境，可以各种方式，无论是导入 jar包 或者 maven 创建，用 idea 在一个空项目上右键 添加框架 也可以。

* 创建一个user表，有三个字段，分别是 id,username,password.

```sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
```

* 映射的实体类 User.java

```java
package xyz.yaohwu.entity;

public class User {

    private String username;
    private String password;
    private int id;

    public User() {
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
}

```

User 类有三个属性，id,username,password 分别对应 User 表中的三个字段。

* 创建映射文件User.hbm.xml。完成数据表到实体类的映射

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-mapping PUBLIC "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
        "http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd">

<hibernate-mapping package="xyz.yaohwu.entity">
    <class name="User" table="user">
        <id name="id" column="id">
            <generator class="native"></generator>
        </id>
        <property name="username" column="username"></property>
        <property name="password" column="password"></property>
    </class>

</hibernate-mapping>

```

指明映射关系。User 类对应 user 表，每种属性各自对应的字段。

* hibernate配置文件

```xml
<?xml version='1.0' encoding='utf-8'?>
<!DOCTYPE hibernate-configuration PUBLIC
        "-//Hibernate/Hibernate Configuration DTD//EN"
        "http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">
<hibernate-configuration>
    <session-factory>
        <property name="connection.url"/>
        <property name="connection.driver_class"/>

        <property name="hibernate.connection.driver_class">com.mysql.jdbc.Driver</property>
        <property name="hibernate.connection.url">jdbc:mysql://localhost:3306/hibernate_demo?useSSL=false</property>
        <property name="hibernate.connection.username">yaohwu</property>
        <property name="hibernate.connection.password">******</property>
        <property name="hibernate.dialect">org.hibernate.dialect.MySQLDialect</property>
        <mapping resource="xyz/yaohwu/entity/User.hbm.xml"/>
    </session-factory>
</hibernate-configuration>
```

一些数据库的基本配置和指明有哪些映射文件。更详细的配置可以参考[官方文档](https://docs.jboss.org/hibernate/orm/5.1/userguide/html_single/Hibernate_User_Guide.html#configurations-database-connection)

* 工具类，依据配置生成Session

```java
package xyz.yaohwu.util;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public final class HibernateUtil {

    private static final SessionFactory ourSessionFactory;

    static {
        try {
            Configuration configuration = new Configuration();
            configuration.configure();
            ourSessionFactory = configuration.buildSessionFactory();
        } catch (Throwable ex) {
            throw new ExceptionInInitializerError(ex);
        }
    }

    public static Session getSession() throws HibernateException {
        return ourSessionFactory.openSession();
    }
}
```

* 编写 DAO 和其实现类

```java
package xyz.yaohwu.dao;

import xyz.yaohwu.entity.User;

public interface UserDAO {

    void save(User user);

    User findUserById(int id);
}
```

```java

package xyz.yaohwu.dao.impl;

import org.hibernate.Session;
import org.hibernate.Transaction;
import xyz.yaohwu.dao.UserDAO;
import xyz.yaohwu.entity.User;
import xyz.yaohwu.util.HibernateUtil;

public class UserDAOImpl implements UserDAO {

    @Override
    public void save(User user) {
        try (Session session = getSession()) {
            Transaction ts = session.beginTransaction();
            session.save(user);
            ts.commit();
        }
    }
    @Override
    public User findUserById(int id) {
        try (Session session = getSession()) {
            return session.get(User.class, id);
        }
    }
    private Session getSession() {
        return HibernateUtil.getSession();
    }
}
```

* demo 测试一下

```java
public class Main {

    public static void main(String[] args) {
        User user = new User();
        user.setUsername("yaohwu");
        user.setPassword("password");

        UserDAO dao = new UserDAOImpl();

        dao.save(user);

        user = dao.findUserById(1);
        if (user != null) {
            System.out.println("所查询ID的姓名是: " + user.getUsername());
        }
        System.exit(0);
    }
}
```

这是网上找到的非常简单的 hibernate demo，回顾一下关键的步骤就两点，一个是配置对象关系映射，二是依据配置文件生成Session供调用。

对于配置对象关系映射来说，我们上文中用到的是写配置文件的方式，hibernate 还提供了别的方式，比如使用 Java Persistence API 提供的注解方式。

```java
package xyz.yaohwu.entity;


import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;


/**
 * @author yaohwu
 */
@Entity
@Table(name = "book", uniqueConstraints = {
        @UniqueConstraint(columnNames = {
                "id",
                "author"
        })
})
public class Book {

    @Id
    @Column(name = "id", nullable = false)
    private int id;

    @Column(name = "author", nullable = false)
    private String author;

    public Book() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }
}

补充，即使属性并非基本数据类型，也可以进行配置[@Convert](https://docs.oracle.com/javaee/7/api/javax/persistence/Convert.html)。

```

相应的配置文件 hibernate.cfg.xml 添加:

```xml
<mapping class="xyz.yaohwu.entity.Book"/>
```

同样的，也可以不在 hibernate.cfg.xml 中写对象关系映射，而是更灵活的在创建 session 之前添加：

```java
static {
        try {
            Configuration configuration = new Configuration();
            configuration.configure();
            // here
            configuration.addResource("/xyz/yaohwu/entity/User.hbm.xml");
            configuration.addAnnotatedClass(Book.class);
            ourSessionFactory = configuration.buildSessionFactory();
        } catch (Throwable ex) {
            throw new ExceptionInInitializerError(ex);
        }
    }
```

通过研究 org.hibernate.cfg.Configuration 类的源码，我们可以发现 hibernate 的配置是非常灵活的。hibernate.cfg.xml 中一些数据库的基本配置可以通过各种方式进行配置。

通过这个 demo，我们可以大致了解 hibernate 在这个应用中的架构：

![Architecture](https://docs.jboss.org/hibernate/orm/5.1/userguide/html_single/images/architecture/data_access_layers.svg)

上面就是完整的 demo 展示，我们新的决策平台就是通过这样的方式，完成对于内置数据的增删改查。

### 处理复杂SQL的逻辑

实际应用场景中肯定不止是一个 findSomeById 这样的查询逻辑，因此我们需要在复杂 SQL 的时候有解决方案。

org.hibernate.Criteria 提供了灵活的 API。

```java
@Override
    @SuppressWarnings("unchecked")
    public List<Book> findBooksWrittenByAuthor(String author) {
        Criteria criteria = getSession().createCriteria(Book.class);
        criteria.add(Restrictions.eq("author", author));
        criteria.setMaxResults(10);
        return criteria.list();
    }
```

虽然
>This appendix covers the legacy Hibernate **org.hibernate.Criteria** API, which should be considered deprecated.New development should focus on the JPA **javax.persistence.criteria.CriteriaQuery** API. Eventually, Hibernate-specific criteria features will be ported as extensions to the JPA javax.persistence.criteria.CriteriaQuery.

但，决策平台还是使用这种方案，进行了封装之后供业务逻辑调用。提供了诸多的方案供调用，具体 API 可以参考[文档](https://docs.jboss.org/hibernate/orm/5.1/userguide/html_single/Hibernate_User_Guide.html#appendix-legacy-criteria)。可以实现几乎所有的 sql 查询逻辑，非常的灵活。

#### 结构

鉴于 deprecated，我们这边再看一下 **javax.persistence.criteria.CriteriaQuery** 的查询方案，我发现一个 EntityManager，他是完全不同的两个架构设计。

EntityManager 是 hibernate 对于 JPA 中接口的实现。

javax.persistence.Persistence   给EntityManagerFactory的创建提供一种静态方法的启动类;
javax.persistence.EntityManagerFactory 相当于hibernate的SessionFactory;
javax.persistence.EntityManager 相当与hibernate的Session;
javax.persistence.Query 相当与hibernate的Query,跟hibernate使用hql一样，同样可以使用对象化的查询语言;
javax.persistence.EntityTransaction 相当于hibernate的Transaction;

hibernate ORM 可能未来会更注重对于 JPA 的实现。

通过 JPA API 和 Hibernate API 可以看一下 session 和 entitymanager 两者的关系。

![JPA API vs hibernate API](https://docs.jboss.org/hibernate/orm/5.1/userguide/html_single/images/architecture/JPA_Hibernate.svg)

看[这里](https://www.uml-diagrams.org/index-examples.html) 解释一下 UML 图。 [或者](https://www.cnblogs.com/firstcsharp/p/5327659.html)。

## 和 mybatis 的对比

再研究下 mybatis 之后再出吧。
比较的话，也没有深入研究，都是入门级别的了解，挖个坑，深入理解之后比较一下两者内部实现的不同。

## 参考

[Hibernate_User_Guide](https://docs.jboss.org/hibernate/orm/5.1/userguide/html_single/Hibernate_User_Guide.html)
