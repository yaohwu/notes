---
title: merge-two-git-repo-with-history-left
date: 2023-02-07 14:08:23
tags: git
---

有两个不同地址的库，现在需要把这两个git仓库的dev分支合并到一个新的git仓库的dev分支。
<!-- more -->

两个不同地址的库：

```shell
https://127.0.0.1/mygroup/project1.git，分支dev
https://127.0.0.1/mygroup/project2.git，分支dev
```

现在需要把这两个git仓库的dev分支合并到一个新的git仓库的dev分支：

```shell
https://127.0.0.1/mygroup/allprojects.git
```

按以下步骤操作：

一、克隆allproject到本地

```shell
git clone https://127.0.0.1/mygroup/allprojects.git
```

二、切换到allprojects的dev分支

```shell
git checkout dev
```

三、添加project1远程仓库，命名为project1。

```shell
git remote add project1 https://127.0.0.1/mygroup/project1.git
```

四、从远程仓库拉取project1

```shell
git fetch project1
```

五、将project1仓库拉取dev分支作为新分支checkout到本地，新分支名设定为project1-dev

```shell
git checkout -b project1-dev project1/dev
```

六、切换到allprojects的dev分支

```shell
git checkout dev
```

七、将本地的project1-dev合并到当前的dev分支

```shell
git merge project1-dev
```

如果报错：fatal: refusing to merge unrelated histories … 则使用加上一个参数：

```shell
git merge project1-dev --allow-unrelated-histories
```

同样，合并project2仓库，重复步骤三到七。

八、最后，推送合并后的dev分支到远程即可

```shell
git push origin dev
```
