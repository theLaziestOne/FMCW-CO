%% 基础知识
% 1、雷达可以分辨的频率由采样频率决定，一般是最高采样频率 （但是取不到），简单的理解是，频率越高，在采样时间内
% 相位变化越多，当等于的时候就是处在分辨不出来的时候
% 且这样分析可知存在高频分量被计算到低频之中
%********* 频率越高所对应的距离越大，频率越低所对应的距离越近********%

% 2、毫米波雷达的距离范围由采样频率决定 最高频率由采样频率决定，最低也是间接的由采样频率决定
% 所以最高频率为采样频率所对应的距离，最小距离也就是距离分辨率，由chirp内的采样点数与采样频率共同决定
%********* 因为想要实现频谱的分离 至少得观察到一个周期信号，最多在一个采样能变化不能超过一个周期***********%

% 3、速度的处理与距离类似，因为速度是对相位进行考虑的，因此还是一样的根据周期来确定大小
% 最大可分辨的速度在时间间隔内应该隔离的时间对应相位的变化不超过pi(因为速度有正负) 最小的变化不能再一个周期内不超过2pi

% 注意这里的雷达是TDM-MIMO 对于速度处理增大了时间间隔从而降低了可观测到的最大速度
%% 2023-7-14
% 在此之前一直以为对应的信号是一帧，搞错了，对应的应该是一帧只拿出来了一个拓宽后的chirp因此在这里其实不能测算速度
% 故速度的分辨率在这是没有意义的，但是其对应的分辨率的计算还是对的
% 需要做的事情是根据每一帧仅有的一个采样数据矩阵对目标进行精确的定位
function radar=function_radarParameter()
%% THE DEFINED PARAMETERS
    radar.c=3.0e8;%光速
    radar.fc=7.88e10;%base frequency
    radar.Ts=1.25e-7;% sampling time
    radar.ChirpNum=32;% chirp num 这是题目中说的，但是实际之中只给了一个chirp数据
    radar.fameNum=32;%这里给定的数据的帧数 用来对移动的目标进行定位跟踪的
    radar.L=0.0815;% radius of RX 
    radar.Tc=3.2e-5;% chirp time 
    radar.sweep_slope=7.8986E13;% S
    radar.Na=86;%virtual num of TX*NX
    radar.NT=2;%发射天线数量
    radar.NR=43;%接收天线数量
    
%% undefined but can be computed
    radar.B=radar.Tc*radar.sweep_slope/2;%带宽
    radar.sample_num=radar.Tc/radar.Ts;%采样数
    radar.lambda=radar.c/radar.fc;%波长
    radar.NC=radar.ChirpNum;% 这里因为TDM
    %radar.RxDis=radar.L/((radar.Na)/2-1);%天线间距
    radar.RxDis=radar.lambda/2;
%% KEY PARAMETRS
    radar.disMIN=radar.c/(2*radar.B);%c/(2B) 对于TDM 最好不要根据带宽来计算
    radar.disMAX=radar.c*radar.sample_num/(2*radar.B);%两种计算方式 但是都是根据采样频率1/radar.Ts计算得到的 sample_num* c/(2B)
    radar.velMIN= radar.lambda/(2*radar.Tc*radar.NT*radar.NC);% 最小速度自行计算 找到对应的计算等式 对应计算关系
    radar.velMAX=radar.lambda/(4*radar.NT*radar.Tc);
    % 2D角度也即水平面的夹角 区分一下面型雷达的俯仰角
    %% 不同的是这里的角度与频率是非线性关系，因此范围不再是直接增加系数计算、还是要从关系展开
    radar.sigleMIN2D=radar.lambda/(radar.Na*radar.RxDis)*180/pi;%这里算出来的不再是角度分辨率而是最小角度  因为是非线性关系
    radar.sigleMAX2D=abs(asin(radar.lambda/radar.RxDis/2)*180/pi);
%% 不展开为2的幂次时对应的傅里叶变换的变化点数向量
    radar.rawFFTnum=[radar.fameNum,radar.Na,radar.sample_num];
    % 根据采样FFT的距离索引  因为是线性关系
    radar.RIndex=0:1:radar.rawFFTnum(3)-1;
    radar.rawR=radar.RIndex*radar.disMIN;
    % 根据chirp 数计算得到的多普勒速度索引 线性关系
    radar.DIndex=-(radar.NC):1:(radar.ChirpNum/2/radar.NT);%这里是因为在这里速度有正负的区分；
    radar.rawD=radar.DIndex*radar.velMIN;
    % 根据天线数得到对应角度
    radar.AIndex=-(radar.Na/2):1:(radar.Na/2);
    radar.rawA=(asin(radar.AIndex*(radar.lambda/(radar.RxDis*radar.Na))))*180/pi;
    
%% 考虑将其傅里叶变化为2的幂次
    radar.RFFTnum=256;%本身就是2的幂次不用算了
    radar.DFFTnum=16;%radar.ChirpNum/radar.NT;jisuan dedao 等效 后续要对相位进行补偿因为有间隔
    radar.AFFTnum=128;%虚拟天线数量是86
    radar.FFTnum=[radar.DFFTnum,radar.AFFTnum,radar.RFFTnum]; 
    %% 此时区别就在于对应的最大值不变 都是将其与频域对应起来求
    
end