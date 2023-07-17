%% 基础知识
% 这里的是TDM 也就是时分复用chirp时间被拉长了
% 注意到这里采样点数是一个T_a(也就是单个天线发射时间)内的点数 128
% 2发4收
% 线性调频255 也就是一帧有255个chirp 
% 相机的帧率是 30/fps
% 采样率 4e6
% 所有的单位按照标准单位
function radar=radarPrameters()
%% 给定参数或者是常规已知参数
    radar.c=3.0e8;                      % 光速
    radar.fc=77e9;                      % GHZ base frequency
    radar.samplingFrequenccy=4e6;       % 采样率
    radar.Ts=1/radar.samplingFrequenccy;% sampling time
    radar.sweep_slope=21e12;            % 调频斜率 注意这里很多时候都是以微秒为单位 因为chirp时间长度一般是微秒
    radar.Na=8;                         % 虚拟天线数量
    radar.NT=2;                         % 发射天线数量
    radar.NR=4;                         % 接收天线数量   
    radar.chirpNum=255;                 % chirp数
    radar.sample_num=128;               % 采样数
    radar.frameNum=899;
    radar.B=0.67e9;                     % 带宽 这里是单个天线的调频斜率
%% undefined but can be computed
    radar.Ta=32e-6;                         % 因为这里是时分复用
    radar.Tc=radar.Ta*radar.NT;             % 一整个chirp的时间 这里应该是2Ta
    radar.lambda=radar.c/radar.fc;          % 波长
    radar.RxDis=radar.lambda/2;             % 阵元间距
%% KEY PARAMETRS
    radar.disMIN=radar.c/(2*radar.B);                           % c/(2B) 对于TDM 最好不要根据带宽来计算
    radar.disMAX=radar.c*radar.sample_num/(2*radar.B);          % 两种计算方式 但是都是根据采样频率1/radar.Ts计算得到的 sample_num* c/(2B)
    radar.velMIN=radar.lambda/(2*radar.Tc*radar.chirpNum);      % 最小可分辨速度 
    radar.velMAX=radar.lambda/(4*radar.Tc);                     % 最大不模糊速度 根据多普勒导致的频移计算而来不能超过Π 否则就出现了速度模糊                                                            
    %% 不同的是这里的角度与频率是非线性关系，因此范围不再是直接增加系数计算、还是要从关系展开
    % 2D角度也即水平面的夹角 区分一下面型雷达的俯仰角
    radar.sigleMIN2D=radar.lambda/(radar.Na*radar.RxDis)*180/pi;        %这里算出来的不再是角度分辨率而是最小角度  因为是非线性关系
    radar.sigleMAX2D=abs(asin(radar.lambda/radar.RxDis/2)*180/pi);
%% 不展开为2的幂次时对应的傅里叶变换的变化点数向量
    % 根据采样FFT的距离索引  因为是线性关系
    radar.RIndex=0:1:radar.sample_num-1;
    radar.rawR=radar.RIndex*radar.disMIN;   % 距离对应索引
    % 根据chirp 数计算得到的多普勒速度索引 线性关系
    radar.DIndex=-(radar.chirpNum-1)/2:1:((radar.chirpNum-1)/2);%这里是因为在这里速度有正负的区分；
    radar.rawD=radar.DIndex*radar.velMIN;   % 多普勒速度 对应索引
    % 根据天线数得到对应角度
    radar.AIndex=[-(radar.Na)/2:-1,1:radar.Na/2];                % 角度的计算感觉有点不对
    radar.rawA=(asin(radar.AIndex*(radar.lambda/(radar.RxDis*radar.Na))))*180/pi;% 角度对应索引
%% FFT点数 自主设置对应的傅里叶变换点数
    radar.FFTnum=[128,255,64];
    radar.R=(0:127)*radar.disMAX/128;
    radar.D=(-127:127);
    radar.D=radar.D*radar.velMAX/127;
    radar.A=(asin((-32:1:32-1)*(radar.lambda/(radar.RxDis*32))))*180/pi;
end