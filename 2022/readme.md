# 文件

1. 2022A

    2022华为杯数学建模A题数据
2. CS-Recovery-Algorithms-master

    压缩感知恢复算法

3. matlab

    Matlab代码

4. references
   
   参考文档

# 一维离散傅里叶变换（1-DFT）

## 变换公式

$$X[k] = \sum\limits_{n = 0}^N {x[n]{e^{ - j(2\pi /N)kn}}} ,0 \le k \le N - 1.$$

## 性质

1. 若输入向量$x$长为N，则DFT后的输出向量$X$长为N。
   
2. $X$中第$k$个值与第$N-k$个值互为共轭，反映到频率上为$(0,pi)$与$(-pi,0)$，反映到物理量上为正值与负值。
   
3. 若采样频率为$f_s$，则$X$中第$k$个值所代表的频率分量为$f = {{f_s} \times \min (k,N - k)}$。
   
4. 频率-距离对应式为：

    $$f = {{S2dT_k} \over c}$$

    $S$：调频斜率

    $d$：信源距离

    $T_k$：采样周期

    $c$：光速

5. 频率-角度对应式为：

    $$f = {{\Delta d\sin (\theta )} \over \lambda }$$
    
    $\Delta d$：阵元间距
    
    $\theta$：信源到达角
    
    $\lambda$：毫米波波长

6. 频率-速度对应式为：

    $$f = {{2 v{T_c}} \over \lambda }$$
    
    $v$：信源速度
    
    $T_c$：chirp周期
    
    $\lambda$：毫米波波长

## 参考

<https://zhuanlan.zhihu.com/p/71582795>

# Multi Signal Classification(MUSIC)
## 原理
对输入信号$X$求自相关矩阵$R_x$及其特征值$e$与特征向量$v$，大特征值对应$X$中的信号子空间，小特征值对应与$X$中的噪声子空间。依据伪谱（由$R_x,e,v,a$构造，a为信号频率响应向量）在信源频率上较大，而在其他频率上较小，因此遍历感兴趣频带上的伪谱即可对信源频率进行超分辨识别。
## 算法步骤
0. 对于输入信号$X_{N \times M}$，$N$为信号长度，$M$为信号数
   
1. 计算自相关矩阵

    $${R_x} = {{{X^H}X} \over N}$$

2. 计算降序特征值$e$即对应特征向量$v$
   
3. 提取信源数量或给定信源数量$n$
   
4. 构造感兴趣频带
   
   $$\omega  = \begin{bmatrix} {{\omega _1}} & {{\omega _2}} &  \cdots  & {{\omega _w}} \end{bmatrix}$$
   
5.  构造信号频率响应向量
   
    $$a({\omega _i}) = \begin{bmatrix} {{e^{ - j0}}} & {{e^{ - j{\omega _i}}}} &  \cdots  & {{e^{ - j(M - 1){\omega _i}}}} \end{bmatrix} ^\top$$

6.  构造伪谱

   $${P(\omega _i)} = 1/({a(\omega _i)^H} GG^Ha(\omega _i) ),$$

   $${G} = \begin{bmatrix}{{v_{n + 1}}}& {{v_{n + 2}}}& \cdots &{{v_N}}\end{bmatrix}.$$

7.  寻找$P(\omega _i)$尖峰对应频率，计算物理量。

8. 频率-距离对应式为：

    $$\omega = 2 \pi \times {{S2dT_k} \over c}$$

    $S$：调频斜率

    $d$：信源距离

    $T_k$：采样周期

    $c$：光速

9.  频率-角度对应式为：

    $$\omega = 2 \pi \times {{\Delta d\sin (\theta )} \over \lambda }$$
    
    $\Delta d$：阵元间距
    
    $\theta$：信源到达角
    
    $\lambda$：毫米波波长

10. 频率-速度对应式为：

    $$\omega = 2 \pi \times {{2 v{T_c}} \over \lambda }$$
    
    $v$：信源速度
    
    $T_c$：chirp周期
    
    $\lambda$：毫米波波长


## 参考

[music原理](https://blog.csdn.net/I_am_mengxinxin/article/details/106046389)

[music求角度](https://blog.csdn.net/zhangziju/article/details/100730081)

# 二维离散傅里叶变换（2-DFT）

## 变换公式

$$X(u,v) = {1 \over {MN}}\sum\limits_{x = 0}^{M - 1} {\sum\limits_{y = 0}^{N - 1} {x(x,y){e^{ - j2\pi (ux/M + vy/N)}}} } .$$

## 性质

1. $X$四个角上为零频分量，中心为高频分量，需要将零频分量转移到中心，转移后为$X'$。
   
2. 若$x$方向采样频率为$f_x$，则$X'$第$k$列所代表的频率分量为$|f_x \times ( k - N / 2 )|$
   
3. 若$y$方向采样频率为$f_y$，则$X'$第$k$行所代表的频率分量为$|f_y \times ( k - M / 2 )|$

## 参考

<https://zhuanlan.zhihu.com/p/36377799>

<https://blog.csdn.net/nuaahz/article/details/90719605>

# 频谱细化傅里叶变换（ZoomFFT）

## 频率分辨率

设采样频率为$f_s$，采样点数为$N$，则频率分辨率为$f_s/N$，频率上限为$f_s/2$。

设细化倍数为D，则细化后频率分辨率为$f_s/（ND）$

## 算法步骤
1. 确定感兴趣的频带中心$f_e$。
2. 将输入信号由频率$f_e$频移至零频。
3. 低通滤波避免频谱混叠。
4. 按$1/D$重采样，并补零至原信号长度$N$。
5. 对重采样信号进行FFT，将得到的结果重新频移到$f_e$。

## 参考
<https://blog.csdn.net/yhcwjh/article/details/113772955>

[Zoomfft算法的实现](https://xueshu.baidu.com/usercenter/paper/show?paperid=b420324564f75242b735d674c485c03f)