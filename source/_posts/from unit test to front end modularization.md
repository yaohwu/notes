---
title: 从单元测试出发看前端和前端模块化
date: 2018-06-20 18:02:00
tags: [unit-test,front-end]
---

> 代码是为了什么，当然是为了重复运行。如何保持unit test代码的稳定？主要靠好的API设计。API切实正确切割了需求，那么在重构的时候API就基本不用变化，unit test也不用重写。以后你重构的时候，只要你的unit test覆盖的够好，基本跑一遍就知道有没有改成傻逼。可以节省大量的时间。所以那些专门写不需要维护的软件的人，讨厌测试，也是情有可原的。
> 作者：vczh
> 链接：[https://www.zhihu.com/question/28729261/answer/94964928](https://www.zhihu.com/question/28729261/answer/94964928)
> 来源：知乎
> 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

<!-- more -->

## 单元测试

> 代码是为了什么，当然是为了重复运行。如何保持unit test代码的稳定？主要靠好的API设计。API切实正确切割了需求，那么在重构的时候API就基本不用变化，unit test也不用重写。以后你重构的时候，只要你的unit test覆盖的够好，基本跑一遍就知道有没有改成傻逼。可以节省大量的时间。所以那些专门写不需要维护的软件的人，讨厌测试，也是情有可原的。
> 作者：vczh
> 链接：[https://www.zhihu.com/question/28729261/answer/94964928](https://www.zhihu.com/question/28729261/answer/94964928)
> 来源：知乎
> 著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

由于我们一年之中，超过一半的时间都是在做软件维护工作，因此我们需要单元测试帮助提高效率节省时间。而且当去重构某些模块的时候，甚至可能帮助设计 API。

对于我们后端的 java 代码，之前也是有分享过，可以使用 [EasyMock 单元测试](https://yaohwu.xyz/#/posts/4)去做，而且 10 之后单元测试也写的如火如荼。

那么对于前端代码，应该怎么写单元测试呢？

## 前端原有的测试方案

### 原有分类

我们原有的前端测试大致分为两部分。

一部分是使用 [Qunit](http://qunitjs.com/) 通过我们自身的 servlet 处理对于测试页面的请求，加载一些写的单元测试到浏览器执行然后结果展现到页面上。

另外一部分是使用 [casperjs](http://casperjs.org/) 框架编写一些自动化脚本持续集成到 Jenkins 中，主要完成一些在浏览器端交互方面的测试。

其实这也说明了，在前端的代码中，我们要针对两种类型的代码做测试。

一种就是对应我们使用 Qunit 写的部分单元测试，大部分是针对一些和前端 UI 不耦合的代码，包括一些工具函数，以及一些抽象的代码，和 UI 不耦合。

另外一种就是和 UI 耦合非常严重的代码，应该是我们的大部分代码，使用 casperjs 框架去完成针对 ui 交互部分的测试。

### 原有测试下的问题

当前前端单元测试方案可能存在的问题。

1. 使用 Qunit 写的需要在浏览器端执行，难持续集成。PS.当然可以再通过 casperjs 去针对 Qunit 部分的测试再去写测试，麻烦。
2. 使用 casperjs 做测试，我们需要做的工作比较多。又要做模板，又要写测试。
3. 和 UI 的耦合迫使我们只能使用 casperjs 这种复杂的方案，而不能在服务端运行 js 完成测试。

### 如何解决这些问题

1. 借助 nodejs，我们可以非常方便的将和 UI 不耦合的代码直接在服务端运行和测试。因为没有 ui 交互的部分，这些代码其实完全是 pure js 代码，和 server-side js 代码区别很小。(很小？)
2. 使用 casperjs 写测试，是不是能够跳过做模板的这一步？
3. 前端的代码能不能和 UI 降低耦合，方便使用更简单的方式去写单元测试，而不是使用 caspserjs。

## 新的测试方案

### 新分类

其实和原有的分类没有什么大的区别。我们在 旧分类中也解释了，前端代码中一部分是我们能够使用 nodejs 运行并测试的代码，另外一部分是借助浏览器去完成运行和测试的代码。

1. 能够直接借助 nodejs 运行和测试的部分。
2. 想办法借助 nodejs 运行和测试的部分。

不同于旧有测试方案分类的主要有三点：

1. 不再使用自身的 servlet 处理测试请求然后在浏览器执行测试；而是直接借助 nodejs 完成测试。
2. 还是使用 casperjs 来完成耦合交互的前端代码测试，但是跳过模板制作，而是直接写脚本。
3. 降低代码同交互部分不需要的耦合，使能够直接使用 nodejs 进行测试的代码所占比例提高。

### 直接借助 nodejs 运行的代码

其实我们原本使用的 [Qunit](http://qunitjs.com/) 也提供了 nodejs 运行的版本。详细见官网。

完成安装配置之后，写一段 js 代码：

```javascript
var QUnit = require("qunit");
var assert = require("assert");

QUnit.test("hello test1", function (assert) {
    assert.ok(1 === 1, "Passed!");
});

QUnit.test("hello test2", function (assert) {
    assert.equal(1, 2, "failed!");
});
```

使用 qunit 提供的 cli 运行一下：

```shell
$ qunit
TAP version 13
ok 1 hello test
not ok 2 hello test
  ---
  message: "failed!"
  severity: failed
  actual: 1
  expected: 2
  stack:     at Object.<anonymous> (E:\release10.0\fine-js-test\test\use-qunit-test.js:10:12)
    at runTest (E:\release10.0\fine-js-test\node_modules\qunit\qunit\qunit.js:1530:30)
    at Test.run (E:\release10.0\fine-js-test\node_modules\qunit\qunit\qunit.js:1516:6)
    at E:\release10.0\fine-js-test\node_modules\qunit\qunit\qunit.js:1737:12
    at advanceTaskQueue (E:\release10.0\fine-js-test\node_modules\qunit\qunit\qunit.js:1129:6)
    at advance (E:\release10.0\fine-js-test\node_modules\qunit\qunit\qunit.js:1110:4)
  ...
1..2
# pass 1
# skip 0
# todo 0
# fail 1
```

这是 qunit 提供的运行在 node 之上的测试方案。

既然我们原本就没有使用这种，并且 qunit 是比较老的框架了，和更流行的测试框架 mocha，它存在很多的缺点，诸如扩展性差，配置项复杂，异步测试复杂等。

因此我们可以直接使用更好的测试框架 [mocha](https://mochajs.org/)。

这边主要分享一下 mocha。

#### mocha

##### 接口类型INTERFACES

mocha的测试接口类型指的是集中测试用例组织模式的选择。Mocha提供了BDD(Behavior Driven Development),TDD(Test Driven Development),Exports,QUnit和Require-style几种接口。

* BDD

BDD测试提供了describe()，context()，it()，specify()，before()，after()，beforeEach()和afterEach()这几种函数。

context()是describe()的别名，二者的用法是一样的。最大的作用就是让测试的可读性更好，组织的更好。相似地，specify()是it()的别名。

```javascript
describe('Array', function () {
    before(function () {
        console.log('Array before');
    });

    after(function () {
        console.log('Array after')
    });

    beforeEach(function () {
        console.log('Array before for each')
    });

    afterEach(function () {
        console.log('Array after for each')
    });

    describe('#indexOf()', function () {
        describe('when not present', function () {
            it('should not throw an error', function () {
                (function () {
                    [1, 2, 3].indexOf(4);
                }).should.not.throw();
            });
            it('should return -1', function () {
                [1, 2, 3].indexOf(4).should.equal(-1);
            });
        });
        describe('when present', function () {
            it('should return the index where the element first appears in the array', function () {
                [1, 2, 3].indexOf(3).should.equal(2);
            });
        });
    });
});
```

相应的执行结果：

```shell
Array before
Array before for each
Array after for each
Array before for each
Array after for each
Array before for each
Array after for each
Array after
```

* TDD

TDD风格的测试提供了suite(), test(), suiteSetup(), suiteTeardown(), setup(), 和 teardown()这几个函数:

```javascript
suite('Array', function () {

    suiteSetup(function () {
        console.log('suite set up');
    });

    suiteTeardown(function () {
        console.log('suite tear down');
    });

    setup(function () {
        // ...
    });
    teardown(function () {
        // ...
    });

    suite('#indexOf()', function () {
        test('should return -1 when not present', function () {
            assert.equal(-1, [1, 2, 3].indexOf(4));
        });
    });
});
```

```shell
mocha --ui tdd test/use-mocha-test.js


  Demo
    test1
      √ should equal

  Array
Array before
    #indexOf()
      when not present
Array before for each
        √ should not throw an error
Array after for each
Array before for each
        √ should return -1
Array after for each
      when present
Array before for each
        √ should return the index where the element first appears in the array
Array after for each
Array after

  Array
suite set up
    #indexOf()
      √ should return -1 when not present
suite tear down


  5 passing (15ms)

```

ps. mocha 默认使用 bdd 接口，如果想要更换接口类型，需要使用在 cli 中提供的 --ui 参数 *-u, --ui \<name\>                         specify user-interface (bdd|tdd|qunit|exports)*

* EXPORTS

EXPORTS 的写法有的类似于 Mocha 的前身 [expresso](https://github.com/visionmedia/expresso) ，键 before, after, beforeEach, 和afterEach都具有特殊的含义。对象值对应的是测试集合，函数值对应的是测试用例。

```javascript

module.exports = {
  before: function() {
    // ...
  },

  'Array': {
    '#indexOf()': {
      'should return -1 when not present': function() {
        [1,2,3].indexOf(4).should.equal(-1);
      }
    }
  }
};

```

* QUNIT

QUNIT 风格的测试像TDD 接口一样支持 suite 和 test 函数，同时又像 BDD 一样支持 before(), after(), beforeEach(), 和 afterEach()等 hook 函数。

```javascript
/*qunit*/

var chai = require('chai'), assert = chai.assert, should = chai.should();

var ok = assert.isOk;

suite('Array');

test('#length', function () {
    var arr = [1, 2, 3];
    ok(arr.length === 3);
});

test('#indexOf()', function () {
    var arr = [1, 2, 3];
    ok(arr.indexOf(1) === 1);
    ok(arr.indexOf(2) === 1);
    ok(arr.indexOf(3) === 2);
});

suite('String');

test('#length', function () {
    ok('foo'.length === 3);
});


suite("group a");
before(function () {
    //..
});
afterEach(function () {
    console.log('after');
});

test("a basic test example", function () {
    assert.ok(true);
});
test("a basic test example 2", function () {
    ok(true);
});

```

* REQUIRE

REQUIRE 可以使用 require 方法引入 describe 等函数，同时，你可以为其设置一个别名。如果你不想在测试中出现全局变量，这个方法也是十分实用的。

```javascript
var testCase = require('mocha').describe;
var pre = require('mocha').before;
var assertions = require('mocha').it;
var assert = require('chai').assert;

testCase('Array', function() {
    pre(function() {
        // ...
    });

    testCase('#indexOf()', function() {
        assertions('should return -1 when not present', function() {
            assert.equal([1,2,3].indexOf(4), -1);
        });
    });
});
```

但是这种方案，是有bug的，详见 [issues/956](https://github.com/mochajs/mocha/issues/956)，一个比较旧的 bug 了，如果不使用 node_modules/mocha/bin/mocha 执行这样的 js ，那么 *require('mocha').describe*拿到是*undefined*。

###### 同步和异步SYNCHRONOUS CODE AND ASYNCHRONOUS CODE

使用 mocha 测试异步代码是再简单不过了。只需要在测试完成的时候调用一下回调函数即可。通过添加一个回调函数(通常命名为 done)给 it() 方法，Mocha 就会知道，它应该等这个函数被调用的时候才能完成测试。hook 函数也是如此。

```javascript
var Demo = require('../../src/demo.js');

var chai = require('chai'), assert = chai.assert, should = chai.should();

describe('async test', function () {
    before(function (done) {
        console.log('async test before');
        sucCallback = function () {
            // some success method
            console.log('test before save success');
            done();
        };
        var d = new Demo().save(sucCallback);
    });

    afterEach(function () {
        console.log('async test after each')
    });

    it('async test #save', function (done) {
        sucCallback = function () {
            // some success method
            console.log('save success');
            done();
        };
        var d = new Demo().save(sucCallback);
    })
});
```

### 借助 nodejs 模仿在浏览器运行的代码

casperjs is a navigation scripting & testing utility for the PhantomJS (WebKit) and SlimerJS (Gecko) headless browsers, written in Javascript.

casperjs 需要先安装 PhantomJS 或者 SlimerJS。通过 [get start](http://casperjs.org/) 一步一步就可以。

demo:

```javascript

var casper = require('casper').create();
casper.start('http://casperjs.org/');

casper.then(function() {
    this.echo('First Page: ' + this.getTitle());
});

casper.thenOpen('http://phantomjs.org', function() {
    this.echo('Second Page: ' + this.getTitle());
});

casper.run();
```

```shell

casperjs test/casperjs.demo.js

yaohw@yaohwu MINGW64 /e/release10.0/fine-js-test (master)
$ First Page: CasperJS, a navigation scripting and testing utility for PhantomJS and SlimerJS
Second Page: PhantomJS - Scriptable Headless Browser

```

惨的是：PhantomJS 已经要逐渐没人维护了。[phantomJs之殇，chrome-headless之生](http://www.itboth.com/d/eQbUv2/phantomjs)

[karma](https://karma-runner.github.io/2.0/index.html)

ps. 免去制作模板的步骤指的是，可以直接在 js 中去控制生成控件以及相关 dom , 只要请求到一个能够加载进来所需 完整 js 的地址就可以。

### 新的问题

js 的模块化。

之前vito 做过一个版本的模块化，但是主要解决的是加载finereport.js 的问题。

模块化内容比较多，我不懂得也很多，这次就不怎么分享了。

可以看一下：[js-module-7day](https://huangxuan.me/js-module-7day/#/)

### 前端的问题

上次 vuejs 分享之后，我也在不断想这个事情，就是如何能让我们的前端跟上时代。

为了解决这个问题，我了解了一下我们的 js 代码是怎么加载到浏览器端的。

* 我们自身的模块化

其实我们自身本来就有自己的模块化。

我们不同的前端组件都是散落在不同的 js 文件中，这是一个非常显著的模块化倾向。

但是我们这些又不是真正的模块化，因为我们每一个 js 文件，单独拿到浏览器端是运行不了的。没有解决各个模块之前的依赖问题，在运行单个 js 文件的时候就会有各种undefined。

为了解决这个问题，我们将每个 js 文件在启动服务器的时候拼接起来，放在服务端的一个缓存里面，每次前端发送 op cmd 就从 缓存 中去读 js 代码字符串做响应。

ps：

1. 这个拼接 js 的启动耗时算不算问题？
2. 无论采用何种优化，在高并发场景下，对于 js 等静态资源文件的请求会不会存在锁竞争。

让我们的前端跟上时代的第一步是不是就是改变这种加载方式？

* 从jar包里面拿出来

引入 webpack？ 自己完成编译

最大化的放大前端模块化的优势，同时使得 ide 能够更好的帮助进行前端开发和维护
会不会 更加容易做单元测试？

* 之前的 requirejs 模块化做了什么？

Asynchronous Module Definition 实现异步加载
