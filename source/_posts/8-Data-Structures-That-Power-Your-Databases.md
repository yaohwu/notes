---
title: 8 Data Structures That Power Your Databases
date: 2023-02-07 14:08:23
tags: [data structures,database]
---

介绍学习一下 8 种支撑起数据库的数据结构。

<!-- more -->

## Guide

![8 Data Structures That Power Your Databases](https://cdn.jsdelivr.net/gh/yaohwu/link-image/static/202301302010209-8-data-structures-database.png)

由于到可能回到算法层面，内容会变得很多，我准备的也比较仓促，有很多也没搞懂，因此我们尽可能避免实现层面的问题。

将结构示意和原理示意，然后将优劣势，再最后将实际的应用场景。总结来说，就是上图稍微扩展扩展。

## SkipList 跳表

SkipList ( 跳表 ) 这种数据结构是由*William Pugh*于1990年在在 [Communications of the ACM](https://link.zhihu.com/?target=https%3A//zh.wikipedia.org/w/index.php%3Ftitle%3DCommunications_of_the_ACM%26action%3Dedit%26redlink%3D1) June 1990, 33(6) 668-676 发表了*Skip lists: a probabilistic alternative to balanced trees*，在其中详细描述了他的工作。由论文标题可知，SkipList的设计初衷是作为替换平衡树的一种选择。

### 背景

讲到平衡树，那么就得稍微展开介绍介绍。

树到二叉树到二叉搜索树到平衡树或者跳表，这算是树结构的一个优化链条。

**树结构**，现实生活应该很常见。到计算机领域，最多的是**二叉树**。

![tree-and-binary-tree](https://cdn.jsdelivr.net/gh/yaohwu/link-image/static/202302071539522-tree-binary-tree.png)

- 将一棵树转换为二叉树的方法：
  - 在兄弟之间加一连线；
  - 对每个结点，除了其左孩子外，去除其与其馀孩子之间的联系；
  - 以树的根结点为轴心，将整树顺时针转45度。

二叉树有很多的性能问题，这很显而易见。

因此演变出来，二叉搜索树。

**二叉搜索树**（英语：Binary Search Tree），是指一棵空树或者具有下列性质的[二叉树](https://zh.wikipedia.org/zh-hans/二叉树)：

1. 若任意节点的左子树不空，则左子树上所有节点的值均小于它的根节点的值；
2. 若任意节点的右子树不空，则右子树上所有节点的值均大于它的根节点的值；
3. 任意节点的左、右子树也分别为二叉查找树；

二叉搜索树相比于其他数据结构的优势在于查找、插入的时间复杂度较低，为O(logn)。

#### 性能优化方案

二叉树到二叉搜索树的这优化很容易理解，有序的嘛，有序的对于搜索和排序就很友好，性能就好。

二叉搜索树到平衡树，大致讲一下。

搜索、插入、删除的复杂度等于树高，期望O(logn)，最坏退化为偏斜二元树O(n)，树太深了。对于可能形成偏斜二元树的问题可以经由树高改良后的平衡树将搜寻、插入、删除的时间复杂度都维持在 O(log n)，如AVL树、红黑树等。

但是

> 那么，狗蛋，代价是什么呢？--地狱咆哮《WOW》
>
> 团结是需要付出代价的。--周喆直《流浪地球2》

举个例子，**扁平化管理**。

旋转：几乎所有平衡树的操作都基于树旋转操作（也有部分基于重构，如替罪羊树），通过旋转操作可以使得树趋于平衡。对一棵搜索树进行查询、新增、删除等动作，所花的时间与树的高度h成比例，并不与树的容量n成比例。如果可以让树维持平衡，也就是让h维持在O(logn)的左右，就可以在O(logn)的复杂度内完成各种基本操作。

由于插入过程中可能需要多次旋转，导致插入效率较低，因而才有了在工程界更加实用的红黑树。

但是红黑树有一个问题就是在并发环境下使用不方便，比如需要更新数据时，Skip需要更新的部分比较少，锁的东西也更少，而红黑树有个平衡的过程，在这个过程中会涉及到较多的节点，需要锁住更多的节点，从而降低了并发性能。

> SkipList还有一个优势就是实现简单，SkipList的实现只花了2个小时，而红黑树，我可能得2天。

### 原理示意

先看几个树结构的示意动画

[visualization/Algorithms](https://www.cs.usfca.edu/~galles/visualization/Algorithms.html)

看跳表的原理，跳表使用概率均衡技术而不是使用强制性均衡，因此，对于插入和删除结点比传统上的平衡树算法更为简洁高效。

这也就是 probabilistic  的来源。

基础跳表

![basic](https://cdn.jsdelivr.net/gh/yaohwu/link-image/static/202302071615993-skiplist-1.png)

查找 19 的过程

![find 19](https://cdn.jsdelivr.net/gh/yaohwu/link-image/static/202302071616650-sliplist-2.png)

随机生成的跳表

![random generacted skiplist](https://cdn.jsdelivr.net/gh/yaohwu/link-image/static/202302071617885-skiplist-3.png)

### 典型的应用场景

#### redis 的有序集合，[为什么 redis 里面要使用跳表来实现](https://news.ycombinator.com/item?id=1171423)？

There are a few reasons:

\1) They are not very memory intensive. It's up to you basically. Changing parameters about the probability of a node to have a given number of levels will make then *less* memory intensive than btrees.

\2) A sorted set is often target of many ZRANGE or ZREVRANGE operations, that is, traversing the skip list as a linked list. With this operation the cache locality of skip lists is at least as good as with other kind of balanced trees.

\3) They are simpler to implement, debug, and so forth. For instance thanks to the skip list simplicity I received a patch (already in Redis master) with augmented skip lists implementing ZRANK in O(log(N)). It required little changes to the code.

About the Append Only durability & speed, I don't think it is a good idea to optimize Redis at cost of more code and more complexity for a use case that IMHO should be rare for the Redis target (fsync() at every command). Almost no one is using this feature even with ACID SQL databases, as the performance hint is big anyway.

About threads: our experience shows that Redis is mostly I/O bound. I'm using threads to serve things from Virtual Memory. The long term solution to exploit all the cores, assuming your link is so fast that you can saturate a single core, is running multiple instances of Redis (no locks, almost fully scalable linearly with number of cores), and using the "Redis Cluster" solution that I plan to develop in the future.

简单够用。跳表足够简单 Antirez 很喜欢很满意，除此之外因为内存中的 IO 相对于磁盘来说足够快 所以相对于 IO 次数多并不会造成速度上过大的差距。

## Hash Index

### Hash Index 原理示意

基于哈希表实现，只有精确匹配索引所有列的查询才有效。对于每一行数据，存储引擎都会对所有的索引列计算一个哈希码（hash code），哈希码是一个较小的值，并且不同键值的行计算出来的哈希码也不一样。哈希索引将所有的哈希码存储在索引中，同时在哈希表中保存指向每个数据行的指针。

#### 静态 hash

云端 swift 的 bucket hash，针对 appid 和 yearmonth 的 hash 索引，用于加速指定 appid 和 yearmonth 的查询，使用的就是静态的 hash。

缺点：
一旦确定，是不能够修改的，**必须在实现系统时选择确定的散列函数**。

#### 动态 hash

允许散列函数动态改变，以适应数据库增大或缩小的需要。

当数据库增大或缩小时，可扩充散列可以通过桶的分裂或合并来适应数据库大小的变化，这样可以保持空间的使用效率。此外，由于重组每次仅作用于一个桶，因此所带来的性能开销较低。

- 选择一个具有均匀性和随机性特性的散列函数 h。此散列函数产生的值范围相对较大，是 b 位二进制整数，一个典型的 b 值是 32。
- 把记录插入文件时按需建桶，用小于等于 b 的 i 个位用作附加桶地址表中的偏移量，i 的值会随着数据库大小的变化而增大或者减少。

![dynamic-index](https://cdn.jsdelivr.net/gh/yaohwu/link-image/static/202302071736441-dynamic-index.png)

优点

- 随着记录的增加, 动态散列的性能并不会下降；
- 动态散列有着最小的空间开销。

缺点

- 会增加一次额外的查询定位, 因为在查询桶本身之前还需要查找目录来定位桶；
- 存储区地址表本身可能变得很大；
- 更改存储区地址表的大小是一项代价昂贵的操作。

### 应用场景

#### 非常常用的内存索引方案

## Sorted String Table(SSTable)

ref <https://www.cnblogs.com/Jack47/p/sstable-1.html>

## LSM TREE

ref <https://zhuanlan.zhihu.com/p/181498475>

## B-tree

ref <https://www.yiibai.com/data_structure/b-tree.html>

## Inverted Index

ref <https://www.mubucm.com/doc/2CsWtcrN4Is>

ref <https://www.jianshu.com/p/3d0fc2e77620>

## Suffix Tree

ref <https://www.cnblogs.com/luosongchao/p/3247478.html>

## R-Tree

ref <https://zhuanlan.zhihu.com/p/62639268>

## ref

1. <https://github.com/HiWong/SkipListPro>
2. <https://blog.csdn.net/ict2014/article/details/17394259>
3. <https://rasmuspagh.net/courses/DBT08/>
4. <https://rasmuspagh.net/courses/DBT08/02-hashing.pdf>
