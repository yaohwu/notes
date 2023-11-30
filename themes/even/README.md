# hexo-theme-even

A super simple theme for Hexo.

fork from <https://github.com/ahonn/hexo-theme-even/>

- Use ejs instead of swig.
- Use dartsass instead of sass.

## Screenshots

## Installation

```shell
npm install hexo-renderer-ejs hexo-renderer-dartsass --save
git clone https://github.com/zeed-w-beez/hexo-theme-even themes/even
cp themes/even/_config.yml.example themes/even/_config.yml
```

Modify `yoursite/_config.yml`:

```yaml
# Extensions
## Plugins: http://hexo.io/plugins/
## Themes: http://hexo.io/themes/
theme: even
```

For more options, check out the [document](https://github.com/ahonn/hexo-theme-even/wiki)

## Update

You can update to latest master branch by the following command:

```shell
cd themes/even
git pull
```

## use ejs instead of swig

### 先使用 ChatGPT 把 `swig` 转换为 `ejs` 格式，效果棒棒哒

### 再批量修改一下文件后缀和引用

```shell
cd layout

# rename template file extension:
find . -type f -name "*.swig" -exec sh -c 'mv "$0" "${0%.swig}.ejs"' {} \;

# replate template file reference:
find . -type f -exec sed -i 's/\.swig/\.ejs/g' {} \;
```

### 有些问题需要手动修复一下

转换完肯定是不能直接运行的，还有一些地方需要手动修改下

1. `{%- block content -%}{%- endblock -%}` 改为 `<%- body %>`
1. 如果输出的是转义后的 HTML，需要把 ejs 标签 `<%=` 改为 `<%-`，具体看下面的标签说明（但是像 `page.description` 这样的字段，最好还是保留转义）
1. 转换之后有一些 `partial("xxx.ejs")` 引用是用的变量模式，会报错说找不到，改成直接引用就好了
1. 开发的时候 `hexo s` 会有缓存，遇到没效果的，可以先执行一下 `hexo clean`

### EJS 标签含义

- `<%` '脚本' 标签，用于流程控制，无输出。
- `<%_` 删除其前面的空格符
- `<%=` 输出数据到模板（输出是转义 HTML 标签）
- `<%-` 输出非转义的数据到模板
- `<%#` 注释标签，不执行、不输出内容
- `<%%` 输出字符串 '<%'
- `%>` 一般结束标签
- `-%>` 删除紧随其后的换行符
- `_%>` 将结束标签后面的空格符删除
- 其他语法可以参考[官方文档](https://ejs.bootcss.com/#docs)

## use nunjucks instead of swig

最开始打算是换成 `nunjucks` 的，但是没成功。

```shell
cd layout

# rename template file extension:
find . -type f -name "*.swig" -exec sh -c 'mv "$0" "${0%.swig}.njk"' {} \;

# replate template file reference:
find . -type f -exec sed -i 's/\.swig/\.njk/g' {} \;

# replate extends with include in njk files
find . -type f -name "*.njk" -exec sed -i 's/extends/include/g' {} \;
find . -type f -name "*.njk" -exec sed -i 's/||/or/g' {} \;
find . -type f -name "*.njk" -exec sed -i 's/&&/and/g' {} \;
find . -type f -name "*.njk" -exec sed -i 's/===/==/g' {} \;
find . -type f -name "*.njk" -exec sed -i 's/!==/!=/g' {} \;

find . -type f -name "*.njk" -exec sed -i 's/{%-/{%/g' {} \;
find . -type f -name "*.njk" -exec sed -i 's/-%}/%}/g' {} \;

# Template render error: (unknown path) Error: template not found: _layout.njk
# 搞不定这个错误 ε=(´ο｀*)))唉
# 而且 (hexo-renderer-nunjucks)[https://github.com/hexojs/hexo-renderer-nunjucks] has been archived by the owner on Jul 29, 2023。
# 放弃了，改用 EJS。

```
