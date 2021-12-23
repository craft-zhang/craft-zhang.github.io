# 工程技巧：Architecture Aware Con guration and Scheduling of Matrix Multiplication on Asymmetric Multicore Processors

## 摘要：
非对称多核处理器，共享相同的指令集架构，微架构不同。本文实现大小核ARM上的GEMM。

## 相关工作：
分为两部分实验性评估性能与能效比与异构平台GEMM计算的负载分配策略。本文提出基于BLIS的非对称多核。

## 多线程GEMM-BLIS的实现：
按照GotoBALS的方式，C+=A·B rank-1-update，基于一个基于simd assembly代码实现的micro kernel做五级循环，packing程序由C代码实现。BLIS可以选择运行时选择五级循环中任意一级做并行来适应不同的体系结构。
loop5: 不同的线程执行不同的micro-kernel实例，每个L1 cache要有的相同nr*kc的B panel，并行数量mc/mr，适用于mc较大为几百的情况。
loop4：不同线程公用L2 cache中的mc*kc的A panel，循环的时间可以分摊packing A panel，以及搬运至L2的开销，并行数量nc/nr，nc在大多数架构上可以达到几千的大小。
loop3：不同的线程分别packing A panel到L2 cache，并行数量由m决定，一般是shared L2 cache，所以要按照并行度减小panel A的大小。然而减小mc等同于在loop5并行。
loop2：不推荐，不同线程一起更新C，需要增加避免竞争的机制。
loop1: 从数据共享的角度看，适合于多socket系统，每个cpu有独占的L3.
总结，看上去并行化循环的适当组合是由cache是私有还是共享决定的，loop1是一个好的候选项对于cpu有独占的L3 cache例如multi-sockets系统；如果每个core有独占的L2可以并行loop3，cores共享L2的话可以考虑并行化loop4和loop5。

## 实验条件：
Exynos 5422 = Cortex-A15 quad-core processing cluster +
Cortex-A7 quad-core processing cluster +
128-bit coherent bus interfaces 访问shared DDR3 RAM +
32+32-Kbyte L1 +
ARM Cortex-A15 cores share a 2-Mbyte L2 cache +
ARM Cortex-A7 cores share a smaller 512-Kbyte L2 cache
setting the Linux performance governor with the appropriate frequency limits
r = m = n = k

## 大小核cache优化：
单核affinity网格搜索确定最佳mc和kc，

Multi-threaded BLIS performance on the big and LITTLE clusters：
Cortex-A15 cluster attain
a peak performance of 9.6 GFLOPS. For the Cortex-A7 cluster, the peak performance is close to 2.4 GFLOPS, also attained with four cores.

Architecture-Oblivious BLIS gemm on the big.LITTLE SoC：
BLIS的默认方法，有两个缺点：

- 静态分配任务在不同的core上，在非对称体系结构上负载不均衡。
- loop stride为常量。

实验：
- 粗粒度，cluster间并行，loop1或loop3（考虑到没有L3）都是好的候选策略。
- 细粒度，cluster内并行，loop4和loop5对于shared L2都是好的选择。

静态cache-awared非对称并行方法
创建8条线程，绑定至对应的core上，8条线程的mc、kc相同。结果不是很理想。
优化1粗粒度按峰值划分比例；优化2不同的cluster分别使用自己设置好的最有mc、kc效果更好。
动态cache-awared非对称并行方法
其实还是静态没有动态选择参数的过程，体现在具体实现代码的区别。

## 收获：单一设备的优化，最暴力方法，网格搜索。作者回顾了下经典多线程矩阵乘法的文章，做了一些实验。没有什么insight。