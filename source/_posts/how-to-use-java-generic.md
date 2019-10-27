---
title: 泛型（Generic）-泛型怎么用，来大幅提高代码可读性和易用性
date: 2019-08-14 16:09:35
tags: [generic]
---

> Before generics, you had to cast every object you read from a collection.
If someone accidentally inserted an object of the wrong type, casts could fail at runtime.
With generics, you tell the compiler what types of objects are permitted in each collection.
The compiler inserts casts for you automatically and tells you at compile time if you try to insert an object of the wrong type.
This results in programs that are both safer and clearer, but these benefits come with complications.
In release 1.5, generics were added to Java.

原本以为是一个很简单的东西，后来研究了发现，其实还是有不少知识可以学习。

<!-- more -->

## 正面回答

这个问题可以通过两方面来回答。

1. 怎么来大幅提高代码可读性和易用性？
其中有一种方式叫做用泛型。
2. 泛型怎么用？
继续读本文。

## 什么是范型

范型，其实单独解释这个泛型是很困难的，就比如有人问你什么是书一样，这时候最好的回答就是直接拿一本书放到他面前告诉他，这就是书。

或者我们也可以从功能上来解释，泛型提供了编译时类型安全检测机制，该机制允许在编译时检测到非法的类型，其本质是参数化类型。

## 怎么理解泛型

### 这样

对于泛型来说，网上有一种比较流行的理解方式，就是泛型提供了一种“模板”。

就拿 `ArrayList` 来说，假设需要一种 `String` 的 `ArrayList`，那么需要写一个 `StringArrayList` 类，又需要一种 `Integer` 的 `ArrayList`，那么需要写一个 `IntegerArrayList` 类。

为了减少这种类型的代码越来越多，因此将 `ArrayList` 变成了 `ArrayList<T>`，提供了一种“模板”，可以方便的完成各种类型的 `ArrayList`。

### 不

我不是很赞同这种理解方式，虽然这种理解方式一定程度上确实能帮助我们理解泛型在代码复用方面给我们带来的好处，但是这种对泛型的理解很容易落入片面，因为完全可以不用泛型，就实现这种级别的代码复用，并且这种理解方式不符合 java 语言规范的发展历史，不能让我们看到 java 语言规范内部设计时的思考。

我来说一下我是如何理解的。

泛型是 `java` 在 `1.5` 版本时引入的特性，如果我们现在不用泛型，那么写出的代码就是 `1.5` 版本之前的代码。就拿操作 `ArrayList` 来说。

```java
// 操作一个 String 的 ArrayList
ArrayList strList = new ArrayList();
strList.add("str1");
strList.add("str2");
strList.remove("str1");
String str2 = (String) strList.get(0);

// 操作一个 Integer 的 ArrayList
ArrayList intList = new ArrayList();
intList.add(1);
intList.add(2);
intList.remove(1);
Integer int2 = (Integer) intList.get(0);
```

可以看到，即使是在 `1.5` 版本之前的代码中，需要 `StringArrayList` 或者 `IntegerArrayList` 时，直接使用 `ArrayList` 就可以了，`ArrayList` 可不是直到 `1.5` 才有的，`ArrayList` 中使用 `Object[]` 数组来实现，因为万物都可以向上转型成 `Object` 因此也就不必要每一个类型都有一个 `TypeArrayList`，这已经实现了代码复用。

但是确实又不方便的地方，哪里呢？

1. 需要强制类型转换，不够安全，不够方便；
2. 没有类型检查，往一个类型为 `String` 的 `ArrayList` 的插入一个 `Integer` 对象是可以的。

正是这两个原因，才在 `1.5` 引入的泛型。泛型来的目的是为了解决类型检查以及强制类型转换。泛型，让代码更清楚更安全，和“模板”以及代码复用只有很小的关系。

更清楚，指明类型，无需主动强制转换，直接调用相应方法；更安全，类型检查，提供保证安全的强制转换。

到了这一步，这么明显的好处，显然，在 `1.5` 版本引入泛型的特性是迫在眉睫的，但是有一个问题，怎么兼容？

新加的泛型对于旧代码来说是完全没有意义的，因为旧代码在旧版本上也能够正常运行。但是如何保证引入泛型的同时，旧代码在新版本上也能正常运行呢？

在详细说这个之前，我们先介绍一个名词，叫做 `可具化类型`（`reifiable type`），指的是 在运行期间类型完全可用的类型，例如 声明成 A 类型，那么在运行期间就一直是 A 类型，不会发生变化。

一种方式就是不改旧版本的东西，而是完全来一套新的类库。拿 `ArrayList` 来说，就是保留 `ArrayList`，同时提高一个新的泛化 `ArrayList` 我们假设叫做 `GArrayList`。

这两个是完全不一样的类型，并且都是可具化的类型，这就意味着，在运行时，这两个类库是完全独立的，这样旧代码就只能在旧版本的逻辑中运行，新版本也只能在新版本的逻辑中运行。

旧版本代码向新版本代码迁移变得非常困难，一个应用假如希望迁移到新版本代码中，那么它必须提供两个版本的代码，并且这种兼容方案会在所有代码中飞速传播，如果当时的 `java` 社区采用这种方案，那么我们现在可能学习使用的就是 `java 2`。

这种方式显然不能够满足兼容的需求，因此泛型系统的设计向寻求迁移兼容性上转变，允许现有代码可以用泛型也可以不用，这样不会再彼此独立开发的软件中间加任何依赖。

既然 `ArrayList` 和 `GArrayList` 需要迁移兼容性，那么就不能创造一个完全可具化的泛型系统。怎么办呢，`类型擦除`（`type erasure`）。

其实类型擦除和可具化类型本身就是相对的概念，可具化就是不会被擦除的类型，会进行类型擦除的就不是可具化类型。

`java` 的泛型系统就是借助类型擦除来实现的，类型擦除是一种映射，即将（可能包含参数化类型和类型变量的）类型映射为（不再是参数化类型或类型变量的）类型，也就是无论何种类型的 ArrayList，在编译后都会无类型的 `ArrayList`。

### 类型擦除带来的弊端

到这里，我们已经知道为什么使用类型擦除来实现泛型了。

类型擦除也给 `java` 的泛型系统带来了很多弊端：

1. 因为泛型都是引用类型，最终都会被擦除成 `Object`，因此基本类型会进行包装；
就像 `Object a = 1;` a 其实是 `Integer` 一样；
2. 无法取得带泛型的 `Class`
无论 `ArrayList<String>` 还是 `ArrayList<Integer>` 实例拿到的 `class` 都是 `ArrayList.class`
3. 因为无法获取带泛型的 `Class`，因此也就没办法判断带泛型类型的类型
运行时无法判断 `list` 是 `ArrayList<String>` 还是 `ArrayList<Integer>`
4. 无法实例化泛型 `T`

## 哪三种泛型用法

### 泛型类

```java
public class Box<T> {

    private T t;

    public void add(T t) {
        this.t = t;
    }

    public T get() {
        return t;
    }
}
```

### 泛型接口

```java
public interface Dock<T> {
    void add(T t);
}
```

### 泛型方法

```java
public class GenericMethodTest {
    public static <E> void printArray(E[] inputArray) {
        for (E element : inputArray) {
            System.out.printf("%s ", element);
        }
        System.out.println();
    }
}
```

## 使用泛型注意哪些

### 使用泛型，不要使用原生类型（raw type）

每个泛型都有一个不带任何实际类型参数的类型，那种类型就是原生类型，比如 `ArrayList<T>` 的原生类型是 `ArrayList`。

这一点就是要求我们使用泛型，因为泛型能够代码类型检查并且代码也更清楚，如果使用原生类型，那么就失去了泛型在安全性以及表述性上的优势。

两个例外：

1. `List<String>.class`
2. `o instanceof Set<String>`

```java
if (o instanceof Set){
    Set<?> m = (Set<?>) o;
}
```

`Set`，`Set<Object>`，`Set<?>` 的区别：

```java
public static void main(String[] args) {
        put1(new HashSet<Object>(), "a");
        put2(new HashSet<Object>(), "b");
        put3(new HashSet<Object>(), "c");
    }

    private static void put1(Set<?> objects, Object o) {
        // compile error
        objects.add(o);
    }

    private static void put2(Set<Object> objects, Object o) {
        objects.add(o);
    }

    private static void put3(Set objects, Object o) {
        objects.add(o);
    }
```

**`Set`** 是原生类型，只是为了与引入泛型之前的遗留代码进行兼容和互用而提供的；它脱离了泛型系统，是不安全的。
**`Set<Object>`** 是参数化类型，表示可以包含任何对象类型的一个集合；是安全的。
**`Set<?>`** 则是一个无限制的通配符类型，表示只能包含某种未知对象类型的一个集合；是安全的。

```java
private static int count(Set<?> objects, Set<?> objects2) {
    int count = 0;
    for (Object object : objects) {
        if (objects2.contains(object)) {
            count++;
        }
    }
    return count;
}
```

### 消除非受检警告

在使用泛型编程的过程中，会收到很多编译器警告，这些是使用泛型类型检查的好处，我们应该尽可能的消除这些警告。

如果无法消除警告，也应该始终在尽可能小的范围中使用 `SuppressWarnings` 注解并且加注释来说明原因；永远不要将 `SuppressWarnings` 注解放在类上来消除非受检警告。

### 使用列表优先于数组

数组和泛型相比，有两个不同点：

数组是协变的，泛型是不可变的
例如，`Sub` 是 `Par` 的子类，那么数组类型 `Sub[]` 是 `Par[]` 的子类，但是 `List<Sub>` 和 `List<Par>` 之间没有任何父子类关系；
数组是可具化的，泛型要进行类型擦除
因此，不要出现数组和泛型混用的情况，如果出现这样的情况，优先使用列表而不是数组。

### 优先考虑泛型

这一条看似和第一条重复，其实侧重点不同，第一条侧重使用泛型，这一条侧重定义新的泛型。

当你发现你的代码中需要获取对象并进行转化，那么可以考虑使用泛型了。

### 优先考虑泛型方法

如同类能够从泛型中收益，方法也可以。静态工具方法尤其适合泛型化。

```java
public static <T> Collection<T> unmodifiableCollection(Collection<? extends T> c) {
    return new UnmodifiableCollection<>(c);
}
```

### 利用有限制通配符来提升 `API` 的灵活性

使用 `super`（T 及 T 的所有父类），`extends`（T 及 T 的所有子类） 和 `?`（`? extends Object`，无边界）来提高 `api` 的灵活性。
使用 **交集类型**

```java
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class Main {

    public static void main(String[] args) {
        List<AA> aas = new ArrayList<AA>();
        new Docker<A>().pushAll(aas);
        List<A> as = new ArrayList<A>();
        new Docker<AA>().popAll(as);
    }

    interface A {
        String a();
    }

    interface AA extends A {
    }

    interface B {
        String b();
    }

    static class C<T extends A & B> {
        T t;

        String c() {
            if (t != null) {
                return t.a() + t.b();
            }
            return "null";
        }
    }

    static class Docker<T> {
        Collection<T> ts;

        void pushAll(Collection<? extends T> collection) {
            ts.addAll(collection);
        }

        void popAll(Collection<? super T> collection) {
            collection.addAll(ts);
        }

    }
}

```

## 几个分享会问题

1. 对于 Java 泛型的弊端，我们应该如何规避？
2. 哪种情况下的强转是被认为安全的，可以忽略的？哪些不是？代码中找得到例子么？
3. 哪些非受检警告是很难消除的，代码中能找得到例子么?
4. 举几个数组和泛型冲突的例子？
5. 如何实现一个类型安全的异构容器？

类型安全的异构容器

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Favorites {

    private Map<Class<?>, Object> map = new HashMap<Class<?>, Object>();

    public <T> T get(Class<T> clazz) {
        return clazz.cast(map.get(clazz));
    }

    public <T> void put(Class<T> clazz, T t) {
        if (clazz == null) {
            throw new IllegalArgumentException("clazz should not be null");
        }
        map.put(clazz, t);
    }

    public static void main(String[] args) {
        Favorites favorites = new Favorites();
        favorites.put(String.class, "String value");

        // 局限性1
        Class clazz = getStringClass();
        favorites.put(clazz, 2);
        favorites.put(clazz, new Object());
        // 局限性2
        // error
        // favorites.put(List<String>.class, new ArrayList<String>());
        favorites.put(List.class, new ArrayList<String>());
    }

    private static Class getStringClass() {
        return String.class;
    }
}

```
