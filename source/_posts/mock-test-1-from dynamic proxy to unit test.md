---
title: mock-test 1 从动态代理到单元测试
date: 2018-01-24 23:13:51
tags: unit-test
---

单元测试目的是针对应用中某些模块进行功能验证。
但是在单元测试中我们可能会遇到一些问题:

1. 其他的协同模块没有开发完，单元测试进行不下去
2. 被测试模块需要和一些不容易构造、比较复杂的对象进行交互，测试和测试边界很难划分
3. 不能肯定其它模块的正确性，无法准确的定位问题

<!-- more -->

## 问题

单元测试目的是针对应用中某些模块进行功能验证。
但是在单元测试中我们可能会遇到一些问题:

1. 其他的协同模块没有开发完，单元测试进行不下去
2. 被测试模块需要和一些不容易构造、比较复杂的对象进行交互，测试和测试边界很难划分
3. 不能肯定其它模块的正确性，无法准确的定位问题

情况1，我们这边很少会遇到，最好是能够测试驱动。
情况2，这种现象非常多，比如 actionCMD 的方法的测试就需要构造 HttpServletRequest 和HttpServletResponse 对象，或者说其他的诸如 Calculator 等复杂对象。
情况3，由于我们的部分代码耦合很严重，因此这类情况也很普遍。

我们需要构造一种稳定的对象，简单，内部逻辑都对，能和被测试模块完成配合，形成一个孤立的测试环境。打桩，篱笆。

我们先来看一种最简单的测试。

## 例子

我们有一个计算器 Calculator 类，里面依赖了一个 int 计算模块的加法器。

```java
public class Calculator {
    private Add adder;
    public int add(int x, int y) {
        //do something special
        return adder.add(x, y);
    }
    public void setAdder(Add adder) {
        this.adder = adder;
    }
}
```

```java
public interface Add {

    /**
     * 计算x+y
     *
     * @param x x
     * @param y y
     * @return x+y
     */
    int add(int x, int y);
}
```

加法器 Add 的实现在别的模块中，在 Calculator 类中我们只是调用了 Add 的接口。

现在我们想对 Calculator 类进行测试，不想因为Add实现的错误或者别的因素影响我们针对 Calculator 的测试。

### 普通测试方案

一般的情况下，我们要针对这个做测试，就只能去实现一下 Add 接口，确定 Add 的内部实现是正确的。

```java
    @Test
    public void useCommon() {
        Calculator calculator = new Calculator();
        //给一个Add的实现类
        calculator.setAdder(new Add() {
            @Override
            public int add(int x, int y) {
                return x + y;
            }
        });
        assertEquals(3, calculator.add(1, 2));
    }
```

这样做就会有遇到问题的风险，一个是例子中的 Add 接口比较简单，容易构造，如果是复杂的对象，比如我们前面说到的 HttpServletRequest，就会非常麻烦；
其次是我们还要保证Add实现的逻辑得是完全正确的，针对一个 Calculator 的测试变成了针对 Calculator 测试并实现一个 Add 并对该 Add 实现进行测试。

因此一般我们不采用这种方案，付出的成本很大效果又不好。
因为我们不关心 Add 的实现，那么如果我们在Add内部方法调用之前就返回一个指定的值不就好了么。我们可以借助代理模式来实现这种方案。

### 静态代理测试方案

#### 代理模式

代理模式是为其他对象提供一种代理以便控制对这个对象的访问。

可以详细控制访问某个类的方法，可以在调用被代理对象的方法前做一些前置处理，
在调用被代理对象的方法后做一些后置处理。

比如 明星的经纪人（滑稽）。

假设我们有一个 Add 接口的默认实现类。

```java
/**
 * @author yaoh.wu
 */
public class DefaultAdder implements Add {

    @Override
    public int add(int x, int y) {
        return x + y;
    }
}

```

现在我想有一个加法器，可以在打印出加数和被加数，以及在计算结束后打印出结果。这种需求就包含了前置处理和后置处理，利用代理模式我们可以这样实现。

```java
/**
 * @author yaoh.wu
 */
public class DefaultAdderProxy implements Add {
    private DefaultAdder defaultAdder;

    public DefaultAdderProxy(DefaultAdder defaultAdder) {
        this.defaultAdder = defaultAdder;
    }

    @Override
    public int add(int x, int y) {
        //do before
        System.out.print("x: " + x + " y: " + y + "= ");
        int result = defaultAdder.add(x, y);
        //do after
        System.out.println(result);
        return result;
    }

}
```

这个例子中就包括了静态代理模式一般会包含的三个角色：

1. 抽象角色：Add 接口
2. 真实角色：DefaultAdder 类
3. 代理角色：DefaultAdderProxy 类

这只是一个静态代理，这个代理 DefaultAdderProxy 类是需要我们自己编码的。

基于这种方式，我们可以给出一个静态代理测试方案。

首先我们得实现一个代理类。

```java
/**
 * @author yaoh.wu
 */
public class AdderProxyForTest implements Add {
    private Add adder;

    public AdderProxyForTest(Add adder) {
        this.adder = adder;
    }

    @Override
    public int add(int x, int y) {
        if (x == 1 && y == 2) {
            return 3;
        }
        return adder.add(x, y);
    }
}
```

测试方法：

```java
    @Test
    public void useStaticProxy() {
        AdderProxyForTest adderProxyForTest = new AdderProxyForTest(new Add() {
            @Override
            public int add(int x, int y) {
                //随意写，因为我们是用来测试的，注定走不到被代理类的方法。
                return 0;
            }
        });

        Calculator calculator = new Calculator();
        calculator.setAdder(adderProxyForTest);

        assertEquals(3, calculator.add(1, 2));

    }
```

这样做确实可以不顾及 Add 内部是如何实现的了，上面那个“随意写”的注释也说明了这一点，但是这样你还是得去构造一个复杂的对象，只不过完全可以不再用仔细的去实现其内部方法，同时还得自己去实现一个代理类。麻烦程度还是不小。

### 动态代理测试方案

上面说了静态代理，在测试的时候需要自己去构建代理类。我们可以使用动态代理来避免这个麻烦。

动态代理通过代码生成代理类，可以使用 java 原生的动态代理，也可以使用 javaassist 或者 cglib 等类库实现这样的操作。

还是原来的需求，在计算前打印加数和被加数，在计算后打印结果。

由于无法直接定义代理类，我们需要借助 java.lang.reflect.InvocationHandler 来定义我们需要的代理行为：

```java
/**
 * @author yaoh.wu
 */
public class AddInvocationHandler implements InvocationHandler {

    private Add delegate;

    public AddInvocationHandler(Add delegate) {
        this.delegate = delegate;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable, InvocationTargetException {
        if ("add".equals(method.getName())) {
            Integer x = (Integer) args[0];
            Integer y = (Integer) args[1];
            System.out.print("x=" + x + " y=" + y + " result=");
            Integer result = delegate.add(x, y);
            System.out.println(result);
            return result;
        }
        return method.invoke(delegate, args);
    }
}
```

然后创建一个工厂来生成代理：

```java
/**
 * @author yaoh.wu
 */
public class AdderProxyFactory {

    public static Add createAdderProxy(Add delegate) {
        return (Add) Proxy.newProxyInstance(
                delegate.getClass().getClassLoader(),
                delegate.getClass().getInterfaces(),
                new AddInvocationHandler(delegate));
    }
}
```

我们可以这样使用它：

```java
public static void main(String[] args) {
        Add adder = AdderProxyFactory.createAdderProxy(new DefaultAdder());
        adder.add(1, 2);
    }
```

好了，我们可以使用动态代理的方式进行测试，在使用之前，我们可以完善一下功能使其更加易用。
比如说，我想自定义调用哪些方法（我们的例子中 Add 接口就只有一个方法），方法的参数，方法的返回值或者抛出的异常；我想在测试最终验证方法的调用的种类，顺序，次数等。

完全可以自己造轮子了。

太麻烦了，理是这个理，我也写不出来，写出来也很容易出错。

我们还是引进轮子吧，哦，我们内部已经引进过了，EasyMock.

### EasyMock测试方案

#### 简介

EasyMock 是一套用于通过简单的方法对于给定的接口生成 Mock 对象的类库。它提供对接口的模拟，能够通过录制、回放、检查三步来完成大体的测试过程，可以验证方法的调用种类、次数、顺序，可以令 Mock 对象返回指定的值或抛出指定异常。通过 EasyMock，我们可以方便的构造 Mock 对象从而使单元测试顺利进行。

#### 安装

开源的 github 地址：[EasyMock](https://github.com/easymock/easymock)

#### demo

用 easymock 来进行单元测试大致有几个步骤：

1. 使用 EasyMock 生成 Mock 对象；
1. 设定Mock对象的预期行为和输出；//录制
1. 将 Mock 对象切换为 replay 状态；//回放
1. 使用 Mock 对象进行单元测试；
1. 对 Mock 对象行为进行验证。

```java
    /**
     * 使用Mock的测试方法
     */
    @Test
    public void useMock() {
        Calculator calculator = new Calculator();
        //创建Mock对象
        Add adder = createMock(Add.class);
        calculator.setAdder(adder);
        //录制
        expect(adder.add(1, 2)).andReturn(3).anyTimes();
        //切换为回放状态
        replay(adder);
        //进行单元测试
        assertEquals(3, calculator.add(1, 2));
        //验证Mock对象调用
        verify(adder);
    }
```

### 详细

#### 创建对象

上面的例子中我们使用了静态方法 `EasyMock#createMock()` 来创建的对象,其实他是通过 `createControl().createMock(toMock)`来实现的，先创建一个MocksControl对象用于管理 Mock 对象，然后在调用createMock() 方法生成一个动态代理。

```java
@Override
    public <T> T createMock(String name, Class<T> toMock, ConstructorArgs constructorArgs,
            Method... mockedMethods) {
        if (toMock.isInterface() && mockedMethods != null) {
            throw new IllegalArgumentException("Partial mocking doesn't make sense for interface");
        }

        try {
            state.assertRecordState();
            IProxyFactory proxyFactory = toMock.isInterface()
                    ? interfaceProxyFactory
                    : getClassProxyFactory();
            try {
                //实际上也是一个动态代理
                return proxyFactory.createProxy(toMock, new ObjectMethodsFilter(toMock,
                        new MockInvocationHandler(this), name), mockedMethods, constructorArgs);
            } catch (NoClassDefFoundError e) {
                if(e.getMessage().startsWith("org/objenesis")) {
                    throw new RuntimeExceptionWrapper(new RuntimeException(
                        "Class mocking requires to have Objenesis library in the classpath", e));
                }
                throw e;
            }

        } catch (RuntimeExceptionWrapper e) {
            throw (RuntimeException) e.getRuntimeException().fillInStackTrace();
        }
    }
```

所以说，我们在创建Mock对象的时候，也可以自己先建立一个MocksControl来管理，然后再创建Mock对象。`EasyMock#createMock()`只不过是使用了一个默认的Control。

#### 录制行为

Mock对象有两种状态，一种是 Record，一种是 Replay。
当Mock对象被创建后会自动进入 Record 状态，这时候我们可以对他的行为进行定义。

定义行为大致分为三步：

1. 对 Mock 对象的特定方法作出调用；
1. 通过 org.easymock.EasyMock 提供的静态方法 expectLastCall 获取上一次方法调用所对应的 IExpectationSetters 实例；
1. 通过 IExpectationSetters 实例设定 Mock 对象的预期输出。

这里的源码我没有看懂，IExpectationSetters 这个写法很神奇。
好像每一次调用都被放在ThreadLocal里面，调用之后我就可以拿到对应的调用的方法和参数列表，然后我就可以在当前状态针对这个方法和参数列表去自定义返回值。

EasyMock 在对参数值进行匹配时，默认采用 Object.equals() 方法。

##### 设定预期返回值

Mock 对象的行为可以简单的理解为 Mock 对象方法的调用和方法调用所产生的输出。对 Mock 对象行为的添加和设置是通过接口 IExpectationSetters 来实现的。Mock 对象方法的调用可能产生两种类型的输出：（1）产生返回值；（2）抛出异常。接口 IExpectationSetters 提供了多种设定预期输出的方法，其中和设定返回值相对应的是 andReturn 方法：

``IExpectationSetters<T> andReturn(T value);``

例如：

```java

adder.add(1, 2);
expectLastCall().andReturn(3);
//相当于
expect(adder.add(1, 2)).andReturn(3)；

```

也可以设定一个默认返回值。

``void andStubReturn(Object value);``

##### 设定预期抛出的异常

``IExpectationSetters<T> andThrow(Throwable throwable);``
``void andStubThrow(Throwable throwable);``

##### 设定预期方法的调用次数

常用的设置调用次数的：

``IExpectationSetters<T>times(int count);``

除此之外：

once(): 默认的，被调用一次。
times(int minTimes, int maxTimes): 该方法最少被调用 minTimes 次，最多被调用 maxTimes 次。
atLeastOnce()：该方法至少被调用一次。
anyTimes()：该方法可以被调用任意次。
等。

#### 回放

在生成 Mock 对象和设定 Mock 对象行为两个阶段，Mock 对象的状态都是 Record 。在这个阶段，Mock 对象会记录用户对预期行为和输出的设定。

在使用 Mock 对象进行实际的测试前，我们需要将 Mock 对象的状态切换为 Replay。在 Replay 状态，Mock 对象能够根据设定对特定的方法调用作出预期的响应。

如果是使用默认 Control，那么需要使用 EasyMock#replay(toMock) 来进行；
如果是自定义 Control，那么 control.replay() 就能将该控制器下所有 Mock对象切换为 replay 状态。

#### 单元测试

就不说了。

#### 验证 verify

同 replay 一致，使用对应的 verify() 方法即可完成验证。

默认的Mock对象好像只有调用次数验证。

比如，如果之前 times(2), 但是实际上只是调用了1次，那么在 verify 的时候就会报错。

#### Mock 对象的重用

同 replay 一致，使用对应的 reset() 方法即可重新是 Mock对象回到 Record状态。

#### 预期调用方法的参数匹配

在使用 Mock 对象进行实际的测试过程中，EasyMock 会根据方法名和参数来匹配一个预期方法的调用。EasyMock 对参数的匹配默认使用 equals() 方法进行比较。

除此之外，还有一些内置的参数匹配逻辑，比如说指定类型的对象，一些常用的字符串匹配逻辑，基本的数据类型，大于小于等于，为空不为空等等。

还支持自定义参数匹配器。

只要实现 IArgumentMatcher 接口即可，matches(Object actual) 方法应当实现输入值和预期值的匹配逻辑，而在 appendTo(StringBuffer buffer) 方法中，你可以添加当匹配失败时需要显示的信息。

#### 特殊的Mock对象

我们所创建的 Mock 对象都属于 EasyMock 默认的 Mock 对象类型，它对预期方法的调用次序不敏感，对非预期的方法调用抛出 AssertionError。除了这种默认的 Mock 类型以外，EasyMock 还提供了一些特殊的 Mock 类型用于支持不同的需求。

##### Strick Mock 对象

如果 Mock 对象是通过 EasyMock.createMock() 或是 IMocksControl.createMock() 所创建的，那么在进行 verify 验证时，方法的调用顺序是不进行检查的。如果要创建方法调用的先后次序敏感的 Mock 对象（Strick Mock），应该使用 createStrickMock() 来创建。

##### Nice Mock 对象

使用 createMock() 创建的 Mock 对象对非预期的方法调用默认的行为是抛出 AssertionError，如果需要一个默认返回0，null 或 false 等"无效值"的 "Nice Mock" 对象，可以通过 createNiceMock() 方法创建。

#### 工作原理

前面通过源码，我们已经发现 EasyMock 后台处理的主要原理是利用 java.lang.reflect.Proxy 为指定的接口创建一个动态代理，这个动态代理，就是我们在编码中用到的 Mock 对象。EasyMock 还为这个动态代理提供了一个 InvocationHandler 接口的实现，这个实现类的主要功能就是将动态代理的预期行为记录在某个映射表中和在实际调用时从这个映射表中取出预期输出。

MocksControl 类中包含了两个重要的成员变量，分别是接口 IMocksBehavior 和 IMocksControlState 的实例。

IMocksBehavior 的实现类 MocksBehavior 是 EasyMock 的核心类，它保存着一个 ExpectedInvocationAndResult 对象的一个列表，而 ExpectedInvocationAndResult 对象中包含着 Mock 对象方法调用和预期结果的映射。MocksBehavior 类提供了 addExpected 和 addActual 方法用于添加预期行为和实际调用。

MocksControl 类中包含的另一个成员变量是 IMocksControlState 实例。IMocksControlState 拥有两个不同的实现类：RecordState 和 ReplayState。顾名思义，RecordState 是 Mock 对象在 Record 状态时的支持类，它提供了 invoke 方法在 Record 状态下的实现。此外，它还提供了 andReturn、andThrow、times 等方法的实现。ReplayState 是 Mock 对象在 Replay 状态下的支持类，它提供了 invoke 方法在 Replay 状态下的实现。

有兴趣的可以研究下，在创建 Mock 对象，记录 Mock 对象预期行为，在 Replay 状态下调用 Mock 对象方法 的代码调用时序图。

### 缺陷

EasyMock 不可以实现对静态方法、构造方法、私有方法、final 方法模拟；
不过还有对应的扩展 PowerMock。
PowerMock 也是一个单元测试模拟框架，它是在其它单元测试模拟框架的基础上做出的扩展。通过提供定制的类加载器以及一些字节码篡改技巧的应用，PowerMock 现了对静态方法、构造方法、私有方法以及 final 方法的模拟支持，对静态初始化过程的移除等强大的功能。

我大致试了一下，但是在一些模块上由于我们插件加载机制的问题，好像 PowerMock 测试这些模块的时候会出现问题。

有机会也可以再介绍一下。

## 总结

单元测试是非常重要的，对于我们稳定性的提高具有非常重要的帮助，相信在 EasyMock 和 PowerMock 的帮助先，我们的单元测试覆盖率可以达到 100%。

同时关于代理模式的解释也希望能够给大家在代码结构方面带来思考。

今天的 1+2=3 的例子就讲完了。

## 参考

[EASYMOCK原理浅析](http://shlteater.iteye.com/blog/394191 'EASYMOCK原理浅析')

[EasyMock 使用方法与原理剖析](https://www.ibm.com/developerworks/cn/opensource/os-cn-easymock/ 'EasyMock 使用方法与原理剖析')
