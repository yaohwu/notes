---
title: mock-test 2 EasyMock & PowerMock
date: 2019-03-10 15:57:20
tags: [unit-test]
---

从遇到的问题出发，反向总结一下这段时间写单元测试的一些方法。

<!-- more -->

## 1.EasyMock

EasyMock 主要也就分 mock expect replay 和 verify 这四个过程。

### mock

#### mock 的方式

* 在方法中直接 mock

```java

public class Main {
    @Test
    public void test(){
        // 在方法中直接mock
    Singer defaultSinger = EasyMock.mock(Singer.class);
    Singer strictSinger = EasyMock.strictMock(Singer.class);
    Singer niceSinger = EasyMock.niceMock(Singer.class);
    }
}

```

* 使用注解

```java
@RunWith(EasyMockRunner.class)
public class Main {
    // 使用注解
    @Mock(MockType.STRICT)
    private Singer strictSingerAnnotation;

    @Mock(MockType.NICE)
    private Singer niceSingerAnnotation;

    @Mock
    private Singer defaultSingerAnnotation;
}
```

**使用注解处理一些依赖注入**，例如：
被测试类 VocalConcert 里面依赖了一个 Singer 类。

```java
public class VocalConcert {

    private Singer singer;

    public VocalConcert() {
    }

    public String show() {
        if (singer != null) {
            return "Vocal Concert Show: " + singer.show();
        } else {
            return "Vocal Concert Show: ...";
        }
    }
}
```

那么，这样写就可以直接将 mock 得到的 defaultMockSinger 注入到 concert 当中。

```java
@RunWith(EasyMockRunner.class)
// 或者是 @RunWith(PowerMockRunner.class) 都可以
public class VocalConcertTest {

    @TestSubject
    private VocalConcert concert = new VocalConcert();

    @Mock
    private Singer defaultMockSinger;

    @Test
    public void testVocalConcert() {
        EasyMock.expect(defaultMockSinger.show()).andReturn("defaultMockSinger show").anyTimes();

        EasyMock.replay(defaultMockSinger);

        System.out.println(concert.show());
    }
}
```

如果想使用默认的 test runner，那么可以采用

```java
public class VocalConcertTest3 {

    @Rule
    public EasyMockRule mocks = new EasyMockRule(this);

    @TestSubject
    private VocalConcert concert = new VocalConcert();

    @Mock
    private Singer defaultMockSinger;

    @Test
    public void testVocalConcert() {
        EasyMock.expect(defaultMockSinger.show()).andReturn("defaultMockSinger show").anyTimes();

        EasyMock.replay(defaultMockSinger);

        System.out.println(concert.show());
    }
}
```

#### mock 的策略

* default

默认策略，使用 Easy.mock(XXX.class) 或者 @Mock 注解；

不介意方法是否按照 expect 的顺序进行调用，verify **会**针对所有期望被调用但是实际上没有调用的方法抛出异常。

* strict

strict 策略，使用 Easy.strictMock(XXX.class) 或者 @Mock(MockType.STRICT) 注解；

相比 default 的方式，这种更为严格，所有调用的方法需要严格按照 expect 的顺序进行调用，否则会抛出异常；verify 也**会**针对所有期望被调用但是实际上没有调用的方法抛出异常。

* nice

nice 策略，使用 EasyMock.niceMock(Nice.class) 或者 @Mock(MockType.NICE) 注解；

相比 default 的方式，这种更为宽松，不介意调用顺序和次数，verify **不会**针对所有期望被调用但是实际上没有调用的方法抛出异常。同时，针对未期望的方法调用不会像 default 或者 strict 那样抛出 AssertionError 错误，而是返回对应的空值 0，null 或者 false。

```java
@RunWith(EasyMockRunner.class)
public class SingerTest2 {

    @Mock
    private Singer defaultSinger;

    @Mock(MockType.STRICT)
    private Singer strictSinger;

    @Mock(MockType.NICE)
    private Singer niceSinger;

    @Test
    public void test() {
        // default
        EasyMock.expect(defaultSinger.getName()).andReturn("yaohwu").once();
        EasyMock.expect(defaultSinger.getBirthday()).andReturn(new Date()).once();
        EasyMock.expect(defaultSinger.getName()).andReturn("new yaohwu").once();

        EasyMock.replay(defaultSinger);

        System.out.println(defaultSinger.getBirthday());
        System.out.println(defaultSinger.getName());
        System.out.println(defaultSinger.getName());

        EasyMock.verify(defaultSinger);

        // strict
        EasyMock.expect(strictSinger.getName()).andReturn("yaohwu").once();
        EasyMock.expect(strictSinger.getBirthday()).andReturn(new Date()).once();
        EasyMock.expect(strictSinger.getName()).andReturn("new yaohwu").once();

        EasyMock.replay(strictSinger);

        System.out.println(strictSinger.getName());
        System.out.println(strictSinger.getBirthday());
        System.out.println(strictSinger.getName());

        EasyMock.verify(strictSinger);

        // nice
        EasyMock.expect(niceSinger.getName()).andReturn("yaohwu").once();
        //EasyMock.expect(niceSinger.getBirthday()).andReturn(new Date()).once();
        //EasyMock.expect(niceSinger.getName()).andReturn("new yaohwu").once();

        EasyMock.replay(niceSinger);

        System.out.println(niceSinger.getBirthday());
        System.out.println(niceSinger.getName());
        System.out.println(niceSinger.getName());

        EasyMock.verify(niceSinger);
    }
}
```

#### 局部 mock

部分场景下，只希望 mock 部分方法，针对其余的方法希望能保留默认行为。这种场景一般是由于设计不好，如果非得局部 mock 也可以。

```java
public class SingerTest3 {
    @Test
    public void test() {
        Singer singer =
                EasyMock.partialMockBuilder(Singer.class)
                        .addMockedMethod("getName")
                        .createMock();

        EasyMock.expect(singer.getName()).andReturn("yaohwu");
        EasyMock.replay(singer);

        System.out.println(singer.getName());
        Assert.assertNull(singer.getBirthday());
    }
}
```

#### 注意

1. EasyMock 不能 mock final 和 private 的方法，即使 mock 了，实际执行的还是默认的行为；
2. 对象实例化是通过 [objenesis](http://objenesis.org/) 做到的，和我们的 rpc 反序列化时获取实例策略是一样的，**不会触发任何执行任何构造方法**，因此类中的变量不会被初始化。

### expect

```java
public class TestMain{
    @Test
    public void test(){
        Singer defaultSinger = EasyMock.mock(Singer.class);
        // 对存在返回值的方法进行录制
        EasyMock.expect(defaultSinger.show()).andReturn("fff").once();
        EasyMock.expect(defaultSinger.getName()).andReturn("b").once();
        // 对没有返回值的方法进行录制
        defaultSinger.setName("c");
        EasyMock.expectLastCall()
                .andThrow(new RuntimeException("Error Cannot Reset Name")).once()
                .andVoid().once()
                .andThrow(new RuntimeException("Error Cannot Reset Name For More Times")).anyTimes();
    }
}
```

* times andReturn andThrow 是可以被链式调用的，并且可以是多组组合使用

因此要注意顺序，一般情况，andReturn() 或者 andThrow() 在前，times() 放在最后。

#### andStubXXX

上面使用的 expect 是我们期望进行的录制并希望参与 verify 的，假设部分方法，我们也希望他们对调用做出反应，同时也不在乎他们何时何地被调用多少次，那么可以使用 andStub 开头的方法。

`

EasyMock.expect(defaultMockSinger.getName()).andStubReturn("");
EasyMock.expect(defaultMockSinger.getBirthday()).andStubThrow(new RuntimeException("Error e"));
`

#### 参数匹配

`

EasyMock.expect(dictionary.get(EasyMock.eq(1001L), EasyMock.anyObject(Calculator.class)))
        .andReturn("J").anyTimes();
`

有时候，我们并不确认实际调用的参数是什么或者说实际上的参数是一个范围，那么我们就可以用到参数匹配。

EasyMock 中提供了多种多样的线程的方法来供我们使用。

需要注意的是，**被调用方法的参数要么全部使用确定的值，要么全部使用参数匹配器**，不能出现下面这种场景。

`

EasyMock.expect(dictionary.get(1000L, EasyMock.anyObject(Calculator.class)))
        .andReturn("J").anyTimes();
`

##### 自定义参数匹配器

```java

public class EasyMock{
    // EasyMock.endsWith() 的实现
    public static String endsWith(String suffix) {
            reportMatcher(new EndsWith(suffix));
            return null;
    }
}
```

```java

public class EndsWith implements IArgumentMatcher, Serializable {

    private static final long serialVersionUID = 5159338714596685067L;

    private final String suffix;

    public EndsWith(String suffix) {
        this.suffix = suffix;
    }
    // 匹配规则
    public boolean matches(Object actual) {
        return (actual instanceof String) && ((String) actual).endsWith(suffix);
    }
    // 不匹配时的输出信息
    public void appendTo(StringBuffer buffer) {
        buffer.append("endsWith(\"" + suffix + "\")");
    }
}
```

#### andAnswer() 和 andDelegateTo()

```java
// todo 我没怎么用到，等用到了再补充
```

## verify

```java
public class Test{
    @Test
    public void testA(){
        // 录制
        expect();
        // 设定未回放状态
        replay();
        // 调用业务逻辑进行测试
        test();
        // 验证录制的方法调用的 times() 是否符合预期，如果和预期不符合，会抛出异常显示多或者少
        verrify();
    }
}
```

### reset()

mock 对象是可以被重用的，使用 reset 方法，让他变回起初的“白纸”状态。
还可以通过 reset 修改策略。
resetToNice(mock), resetToDefault(mock), resetToStrict(mock).

## PowerMock

PowerMock 也有和 Mockito 配合的 api, 这里就不关注了，主要说和 EasyMock 配合的。

PowerMock is a Java framework that allows you to unit test code normally regarded as untestable.

处理 EasyMock 不能处理的 mock 场景。

### mock static

#### common mock static

1. 类上加注解 @RunWith(PowerMockRunner.class)
2. 类上加注解 @PrepareForTest(ClassThatContainsStaticMethod.class)
3. mock PowerMock.mockStatic(ClassThatContainsStaticMethod.class)
4. expect EasyMock.expect(ClassThatContainsStaticMethod.xxx())
5. replay PowerMock.replay(ClassThatContainsStaticMethod.class)
6. verify PowerMock.verify(ClassThatContainsStaticMethod.class)

```java
@RunWith(PowerMockRunner.class)
@PrepareForTest({GeneralContext.class})
public class JavaScriptImplTest {

    private static JavaScriptImpl script;
    private static RepositoryDeal repositoryDeal;

    @Before
    public void Before() {
        script = new JavaScriptImpl();
        script.setContent("console.log('a')");
        script.setParameters(new ParameterProvider[]{new Parameter("p1", "中文!+")});
        script.addJSImort("imported.js");

        repositoryDeal = EasyMock.mock(RepositoryDeal.class);
        EasyMock.replay(repositoryDeal);

        PowerMock.mockStatic(GeneralContext.class);
        EasyMock.expect(GeneralContext.getCurrentAppNameOfEnv()).andReturn("webroot").anyTimes();
        GeneralContext.listenPluginRunningChanged(EasyMock.anyObject(PluginEventListener.class));
        EasyMock.expectLastCall().anyTimes();
        GeneralContext.listenPlugin(
                EasyMock.eq(PluginEventType.AfterStop), EasyMock.anyObject(PluginEventListener.class), EasyMock.anyObject(PluginFilter.class));
        EasyMock.expectLastCall().anyTimes();

        PowerMock.replayAll();
    }
    @Test
    public void testCreateJS() {
        // do xxx
    }
}
```

* 注意，PowerMock 的 replayAll 并不会触发 EasyMock 的 replay(xxx) 因此还是要分开调用，EasyMock 只是负责给 PowerMock mock 的对象预设行为，replay 和 verify PowerMock 和 EasyMock 两者还是各走各的。

#### mock partial static or private method

如下的代码中就只是 mock 了  **MimeUtility** 其中的两个方法。
其中 **getDefaultMIMECharset** 不是一个 **public** 的方法。

``` java
// ....
PowerMock.mockStaticPartial(MimeUtility.class, "getDefaultJavaCharset", "getDefaultMIMECharset");
EasyMock.expect(MimeUtility.getDefaultJavaCharset()).andAnswer(new IAnswer<String>() {
    @Override
    public String answer() throws Throwable {
        return "GBK";
    }
}).once().andAnswer(new IAnswer<String>() {
    @Override
    public String answer() throws Throwable {
        return "UTF-8";
    }
}).once();

try {
    PowerMock.expectPrivate(MimeUtility.class, "getDefaultMIMECharset").andAnswer(new IAnswer<String>() {
        @Override
        public String answer() throws Throwable {
            return "GBK";
        }
    }).once().andAnswer(new IAnswer<String>() {
        @Override
        public String answer() throws Throwable {
            return "UTF-8";
        }
    }).once();
} catch (Exception e) {
    Assert.fail(e.getMessage());
}
// ...
```

### mock final

和 mock static 一样
区别仅在于 `PowerMock.mockStatic` 和 `PowerMock.createMock`；

### mock private

用到的不多，如果出现这样的单元测试，优先考虑是不是设计上有问题或者有没有通过 public 方法的单元测试覆盖到的方法。

如果实在需要，可以参考[MockPrivate](https://github.com/powermock/powermock/wiki/MockPrivate)。

### 一些 Mock 技巧

#### @SuppressStaticInitializationFor("xxx.xxx.xxx") 和 suppress 策略

假设单元测试用到了一个其他类的静态方法，但是这个类的初始化中做了很多单元测试不感知的工作，例如可能读取了授权证书等等。
这时候如果使用 powermock 对静态方法进行 mock 会触发这些初始化操作，但是由于相应的模块没有启动，这些初始化可能会失败，导致 mock 不了。

例如：

```java
public class SessionManager {
    private static final Service service = OtherModuleService.getService();

    static {
        authenticateLicense();
        doSomethingSpecialDependsOnOtherModule();
    }
}
```

如果有这样的场景，可以使用 @SuppressStaticInitializationFor("xxx.xxx.xxx") 注解。

```java
@RunWith(PowerMockRunner.class)
@SuppressStaticInitializationFor("com.xx.SessionManager")
public class Test{
}
```

例子：

```java
public class Manager {

    private static final List<Record> RECORDS = new ArrayList<>();

    static {
        System.out.println("Manager Init");
    }
}
```

```java
@RunWith(PowerMockRunner.class)
@PrepareForTest({Manager.class})
//@SuppressStaticInitializationFor("com.v2.yaohwu.gov.Manager")
public class ManagerTest {

    @Test
    public void test() {
        List expected = new ArrayList();
        PowerMock.mockStatic(Manager.class);
        EasyMock.expect(Manager.getAllRecord()).andReturn(expected).anyTimes();

        PowerMock.replayAll();
        List result = Manager.getAllRecord();
        System.out.println(result.size());
    }
}
```

输出：

```shell
Manager Init
0
```

如果放开@SuppressStaticInitializationFor("com.v2.yaohwu.gov.Manager") 的注释，那么输出：

```shell
0
```

@SuppressStaticInitializationFor 可以阻止静态变量的声明以及静态代码块的运行。

如果需要部分变量初始化，那么可以使用 WhiteBox 的 api 对变量进行赋值 例如：

```java
@RunWith(PowerMockRunner.class)
@PrepareForTest({Manager.class})
@SuppressStaticInitializationFor("com.v2.yaohwu.gov.Manager")
public class ManagerTest {

    @Test
    public void test() {

        // 正常测试
        List expected = new ArrayList();
        PowerMock.mockStatic(Manager.class);
        //noinspection unchecked
        EasyMock.expect(Manager.getAllRecord()).andReturn(expected).anyTimes();

        PowerMock.replayAll();
        List result = Manager.getAllRecord();
        System.out.println(result.size());

        // 获取变量 RECORDS 的值
        System.out.println((String) Whitebox.getInternalState(Manager.class, "RECORDS"));
        // 输出 null SuppressStaticInitializationFor 注解阻止了 RECORDS 的初始化

        // 对 Manager 中的私有变量进行赋值
        List expected2 = new ArrayList();
        try {
            // 私有变量 RECORDS 中加入 一个 Manager 私有内部类 Record 的一个实例
            //noinspection unchecked
            expected2.add(Whitebox.newInstance(Whitebox.getInnerClassType(Manager.class, "Record")));
        } catch (ClassNotFoundException e) {
            Assert.fail(e.getMessage());
        }
        // 将变量 RECORDS 赋值
        Whitebox.setInternalState(Manager.class, "RECORDS", expected2);
        // 获取变量 RECORDS 的值
        System.out.println(((List) Whitebox.getInternalState(Manager.class, "RECORDS")).size());
    }
}
```

##### 其他的 suppress 场景

1. suppress(constructor(XXX.class)) 处理构造函数
2. suppress(method(XXX.class, "methodName")) 处理方法
3. suppress(field(XXX.class, "fieldName")) 处理变量

以上都要和 @PrepareForTest(XXX.class) 配合使用。[link](https://github.com/powermock/powermock/wiki/Suppress-Unwanted-Behavior)

#### @PowerMockIgnore

PowerMock 采用自定义类加载器的方式加载被测试类，如果出现类型转换异常或者类加载器形式的错误，那么可以使用 @PowerMockIgnore 注解，让 PowerMock 从系统类加载器中获取类。

出现的类型转换异常：

`xxx.xxx.xxx.xxx cannot be cast to xxx.xxx.xxxProvider`

也不仅仅局限于这个异常，如果你看到你一个不能解决的异常，其中有 package name 的信息，那么可以尝试使用 **@PowerMockIgnore**。

一般这些类有 "javax.crypto.\*","javax.net.ssl.\*","sun.security.ssl.\*" 等。

使用方式：

```java
@RunWith(PowerMockRunner.class)
@PowerMockIgnore({"javax.crypto.*"})
public class XXXTest {
}
```

## 结尾

参考文档

* [easymock](http://easymock.org/)
* [powermock](https://github.com/powermock/powermock/wiki)
* [powermock QA](https://github.com/powermock/powermock/wiki/FAQ)
