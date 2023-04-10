---
title: enum静态变量的初始化
date: 2021-07-23 10:52:23
tags: [java-basic]
---

前两天写代码的时候遇到这样的问题

<!-- more -->

## 问题

前两天写代码的时候遇到这样的问题

```java
import com.x.StorageType;
import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * @author yaohwu
 * created by yaohwu at 2021/7/23 10:52 上午
 */
public enum AdditionHandlerManager {
    INSTANCE;

    private final static Logger logger = Logger.getLogger(AdditionHandlerManager.class);

    private final List<AdditionHandler> handlers = new ArrayList<>();

    AdditionHandlerManager() {
        register(new BiHandler());
        register(new DesignerRealTimeOperateHandler());
    }

    public void register(AdditionHandler handler) {
        handlers.add(handler);
        // here npe happened for logger is null
        logger.info(String.format("addition handler %s register success", handler.getClass().getSimpleName()));
    }

    public void action(String table, StorageType type, String content) {
        for (AdditionHandler handler : handlers) {
            if (handler.accept(table, type)) {
                handler.action(content);
                logger.info(String.format("addition handler %s trigger success", handler.getClass().getSimpleName()));
                break;
            }
        }
    }
}
```

在 register 方法里面，出现了 logger npe 的问题。

## 思考

起初觉得问题很奇怪，不符合我们对于普通类的常识认知，构造方法的执行，肯定是要后于静态变量初始化的，为什么会出现 npe 的问题。

但是后面仔细一下，就明白了，枚举的底层实现其实相当于静态变量，而且这个静态变量相对于其他静态成员是要先初始化的，从 enum 的写法也可以得出结论。

```java
public enum Type{
  Apple;
  private static final String RED = "red";
  private String color;
}
```

必须先完成 Apple 的定义，才能后续书写其他的静态成员。

那么显然，在第一个静态成员初始化的过程中，其他的静态成员必然没有完成初始化，出现 NPE。

实际的 枚举 代码类似

```java
import com.x.StorageType;
import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * @author yaohwu
 * created by yaohwu at 2021/7/23 10:52 上午
 */
public class AdditionHandlerManager {
    public static final AdditionHandlerManager INSTANCE = new AdditionHandlerManager();
    
    private final static Logger logger = Logger.getLogger(AdditionHandlerManager.class);
    
    private final List<AdditionHandler> handlers = new ArrayList<>();

    public AdditionHandlerManager() {
        register(new BiHandler());
        register(new DesignerRealTimeOperateHandler());
    }

    public void register(AdditionHandler handler) {
        handlers.add(handler);
        logger.info(String.format("addition handler %s register success", handler.getClass().getSimpleName()));
    }

    public void action(String table, StorageType type, String content) {
        for (AdditionHandler handler : handlers) {
            if (handler.accept(table, type)) {
                handler.action(content);
                logger.info(String.format("addition handler %s trigger success", handler.getClass().getSimpleName()));
                break;
            }
        }
    }
}
```

这就有疑问了，为什么这样显著的错误，不能在编译器层面去做提示。

搜索时，我发现了 R 大的这篇文 [enum 静态成员的初始化](https://www.iteye.com/blog/rednaxelafx-460981)，在规范中，[jls 8.9.2](https://docs.oracle.com/javase/specs/jls/se8/html/jls-8.html#jls-8.9) 中已经对于构造方法中静态变量的引用进行了编译期的校验，但是对应的代码放在其他方法中，在构造方法红进行调用，那么编译器就没有那么智能去挖掘对应存在的问题了。

![image-20210816005223910][def]

还是要多看书、规范，来避免一些隐藏的坑点。

[def]: https://cdn.jsdelivr.net/gh/yaohwu/link-image/static/BSSmsq.png