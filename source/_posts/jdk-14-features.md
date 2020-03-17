---
title: JDK 14 Features
date: 2020-03-16 09:09:35
tags: [generic]
---

按照计划，明天（ 3 月 17 号） JDK 14 就要发布了，虽然距离真正使用还是比较远，但事先了解一下新特性还是比较好的，

<!-- more -->

按照计划，明天（ 3 月 17 号） JDK 14 就要发布了，虽然距离真正使用还是比较远，但事先了解一下新特性还是比较好的。

## JEP 305 Pattern Matching for instanceof (Preview)

[JEP 305](https://openjdk.java.net/jeps/305) 将会增强 instanceof 的模式匹配。
可以更简洁安全地表示对象类型的判断。

之前我们在代码中使用 instanceof:

```java
// 测试 obj 是 String
if (obj instanceof String) {
    // 转换 obj 变成 String s
    String s = (Sting) obj;
    // use s
    s.length();
}
```

可以发现，上面的写法有三个步骤：

1. 判断类型；
2. 强制类型转换；
3. 使用转换后的类型；

强制类型转换，由于不能确保先进行类型检查，所以是非常不安全的。
使用新的特性能更好的处理这样的问题，并且更简洁：

```java
// 测试 obj 是 String 并转换为 s
if (obj instanceof String s) {
    // use s
    s.length();
}
```

将类型判断和类型转换放在一起，不再会出现遗漏等情况，更加安全，同时从语法上来看也更简洁。
需要注意的是，绑定变量 s 的范围由包含的表达式和语句的语义确定。

例如

```java
if (!(obj instanceof String s)) {
    // no
    .. s.contains(..) ..
} else {
    // yes
    .. s.contains(..) ..
}

if (obj instanceof String s && /* yes */ s.length() > 5) {
    // yes
    .. s.contains(..) ..
}

if (obj instanceof String s || /* no */ s.length() > 5) {
    // no
    .. s.contains(..) ..
}
```

只有在表达式和语义都确认的情况下，s 才能被正确的使用。

这个特性能够帮助我们将代码变得更清晰：

```java
// old
@Override public boolean equals(Object o) {
    return (o instanceof CaseInsensitiveString) &&
        ((CaseInsensitiveString) o).s.equalsIgnoreCase(s);
}

// new
@Override public boolean equals(Object o) {
    return (o instanceof CaseInsensitiveString cis) &&
        cis.s.equalsIgnoreCase(s);
}
```

## JEP 343 Packaging Tool (Incubator)

[JEP 343](https://openjdk.java.net/jeps/343) 将提供一个打包独立 java 应用程序的 cli 工具 jpackage。支持使用 ToolProviderAPI 编程调用，不支持交叉编译，打包格式包括 Windows 上的 msi 与exe，macOS 上的 pkg 和 dmg，Linux 上的 deb 和 rpm。

## JEP 345 NUMA-Aware Memory Allocation for G1

通过 实现 NUMA 感知内存分配，提供了 G1 在大型机器上的性能。

//todo more

## JEP 349 JFR Event Streaming

[JEP 349](https://openjdk.java.net/jeps/349) Expose JDK Flight Recorder data for continuous monitoring.

// todo more

## JEP 352 Non-Volatile Mapped Byte Buffers

[JEP 352](https://openjdk.java.net/jeps/352) Add new JDK-specific file mapping modes so that the FileChannel API can be used to create MappedByteBuffer instances that refer to non-volatile memory.

// todo more

## JEP 358 Helpful NullPointerExceptions

[JEP 358](https://openjdk.java.net/jeps/358) 通过精准描述哪个变量是 null 来提高 jvm 生成的 NPE 的可用性。

这可以说是一个非常好的特性了，在很多代码中，例如：

```java
a.b.i = 99;
a[i][j][3] = 99;
int i = a.get().pop().size();

```

等等这种类型的代码中，一旦其中出现 npe 是很难判断就是哪一个值是 null 的。

但是通过这个新特性，就能够提供更丰富的 null 信息：

```sh
Cannot read field "c" because "a.b" is null;
Cannot load from object array because "a[i][j]" is null
Cannot invoke "x.pop()" because the return value of "a.get()" is null
```

等等；不仅能够精确识别 null，还能提供不能进一步操作的具体原因。对于分析日志定位问题非常有帮助。

要启用这个功能，需要添加 JVM 标识：

> -XX:+ShowCodeDetailsInExceptionMessages

这个功能在未来可能会默认开启。
但是这个有一个风险就是，这个信息可能包含源代码中的变量名。暴露此信息可能被视为安全风险。

## more
