---
title: java 静态方法返回值变化导致的不兼容
date: 2022-11-25 12:30:00
tags: java-basic
---

## 问题

最近一个迭代做了一些改动，其中有一项是 getInstance 方法返回值发生了变化，从原本的接口类型变成了实际的实现类。
主体功能的插件对于这个方法的调用就出现了兼容问题。

<!-- more -->

## 例子

大致讲一个例子。

有一个 Tools 的类，实现如下

```java
/**
 * @author yaohwu
 * created by yaohwu at 2022/11/25 10:58
 */
public class Tools {
 
    public static Serializable say() {
        return "Serializable";
    }
}
```

有一个依赖 Tools 的 Main 函数，

```java
/**
 * @author yaohwu
 * created by yaohwu at 2022/11/25 10:59
 */
public class MainTools {
 
    public static void main(String[] args) {
        System.out.println(Tools.say());
    }
}
```

可以正常编译执行，都很正常。

![common using of tools and main](https://testingcf.jsdelivr.net/gh/yaohwu/link-image/static/20221125120350.png)

现在，将 Tools 的类实现稍加修改，将方法声明的返回值类型改一下，变成

```java
/**
 * @author yaohwu
 * created by yaohwu at 2022/11/25 10:58
 */
public class Tools {
 
    public static String say() {
        return "String";
    }
}
```

这时，仅编译 Tools 类，那么 MainTools 中的 main 函数还能正常执行么？

现在是思考时间！

------

![main after tools changed](https://testingcf.jsdelivr.net/gh/yaohwu/link-image/static/20221125120628.png)

答案是**不能**，会有 NoSuchMethodError 的异常。

## 实际的业务场景

类比一下实际在业务里的场景。

| 模块 | 旧版本                                | 新版本                                      | 兼容检查                                    |
| ---- | ------------------------------------- | ------------------------------------------- | ------------------------------------------- |
| 主体 | Tools return String say 的实现        | Tookls return Serializable say 的实现       | 旧版本主体                                  |
| 插件 | 依赖 String say 的 MainTools 编译版本 | 依赖 Serializable say 的 MainTools 编译版本 | 新版本插件调用出现 NoSuchMethodError 的问题 |

为什么呢？即使重新编译 MainTools 也不会有报错，陷入方法重载的认知里面，签名没变，返回值也只是从接口变成了具体的实现类，应该可以完成重载的协变。

但实际的效果，却是未重新针对 MainTools 编译的情况下，直接执行旧编译的结果会直接抛出错误。这里是有什么新的知识点么？

## 兼容方案

该如何兼容呢？

直接反射，反射依据方法签名进行调用，可以直接拿到对应的结果。
