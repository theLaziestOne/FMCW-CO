function [Target]=ProcessForFMCWdata(data,radar)
%% 雷达数据 可能是三个维度 第一个维度是ADC采样点数 第二个数据：Chirp数量 第三个：Radar.Tx_num*Radar.Rx_num
%% 三个任务 测角 测距 测速 
%% *******************测距测速感觉没好的办法********************************* %%
%% 1、测距 近处能量大主要原因应该是频率泄露
    data=reshape(data,[radar.sample_num,radar.chirpNum,radar.Na]);%换成虚拟天线的三维形式后面对其进行补偿即可
    RangeFFT_mesh=0;
    for i=1:radar.Na
        temp=squeeze(data(:,:,i));temp=fft(temp);temp=abs(temp)/max(max(abs(temp)));
        RangeFFT_mesh=RangeFFT_mesh+temp/radar.Na;
        RangeFFT=0;
        for k=1:radar.chirpNum
            RangeFFT_data=squeeze(data(:,k,i));%这里有一个假设前提就是 目标低速 对其可以做相干
            temp=fft(RangeFFT_data); temp=abs(temp)/max(abs(temp));
            RangeFFT=RangeFFT+temp/radar.chirpNum; %这里取均值选择非相干的形式实现试一下
        end
    end
    RangeFFT=abs(RangeFFT);RangeFFT=20*log10(RangeFFT);
    RangeFFT_mesh=abs(RangeFFT_mesh)/max(max(abs(RangeFFT_mesh)));RangeFFT_mesh=20*log10(RangeFFT_mesh);
    %% 绘制距离曲线
%         figure(1);
%         plot(radar.rawR,RangeFFT);title("距离谱");xlabel("m");ylabel("dB");
%         figure(2);
%         mesh(1:radar.chirpNum,radar.rawR,RangeFFT_mesh);title("距离谱");ylabel("m");xlabel("chirp num");

%% 2、测速
    DopplarFFT_mesh=0;
    for i=1:radar.Na
        temp=squeeze(data(:,:,i));
        temp=fft(temp,size(temp,2),2);temp=fftshift(temp,2);temp=abs(temp)/max(max(abs(temp)));
        DopplarFFT_mesh=DopplarFFT_mesh+temp/radar.Na;
        DopplarFFT=0;
        for k=1:radar.sample_num
            DopplarFFT_data=squeeze(data(k,:,i));  %这里有一个假设前提就是 目标低速 对其可以做相干
            temp=fft(DopplarFFT_data);temp=fftshift(temp);
            temp=abs(temp);temp=temp/max(temp);
            DopplarFFT=DopplarFFT+temp/radar.chirpNum; %这里取均值选择非相干的形式实现试一下
        end
    end
    DopplarFFT=abs(DopplarFFT);DopplarFFT=20*log10(DopplarFFT);
    DopplarFFT_mesh=abs(DopplarFFT_mesh);DopplarFFT_mesh=20*log10(DopplarFFT_mesh);
    %% 绘制速度曲线
%         figure(3);
%         plot(radar.rawD,DopplarFFT);title("速度谱");xlabel("m/s");ylabel("dB");
%         figure(4);
%         mesh(radar.rawD,1:radar.sample_num,DopplarFFT_mesh);title("速度谱");xlabel("m/s");ylabel("smpling num");

    %% RD-FFT测速
    RangeDopplarFFT_mesh=0;
    for i=1:radar.Na
        temp=squeeze(data(:,:,i));
        temp=fft2(temp,radar.sample_num,radar.chirpNum);temp=fftshift(temp,2);temp=abs(temp)/max(max(abs(temp)));
        RangeDopplarFFT_mesh=RangeDopplarFFT_mesh+temp/radar.Na;
    end
%         RangeDopplarFFT_mesh=abs(RangeDopplarFFT_mesh);RangeDopplarFFT_mesh=20*log10(RangeDopplarFFT_mesh);
%         figure(5);
%         mesh(radar.rawD,radar.rawR,RangeDopplarFFT_mesh);title("距离-多普勒谱");ylabel("距离m");xlabel("速度m/s");zlabel("功率 dB");

%% 3、测角 MUSIC要做多普勒补偿还是说所有的都要做相位补偿？
%% ****************************单纯FFT**************************************** %%
RangeAngleFFT_mesh=0;
for i=1:radar.chirpNum
    temp=squeeze(data(:,i,:));
    temp=fft2(temp);temp=fftshift(temp,2);%temp=abs(temp)/max(max(abs(temp)));
    RangeAngleFFT_mesh=RangeAngleFFT_mesh+temp/radar.chirpNum;
end
%         RangeAngleFFT_mesh=abs(RangeAngleFFT_mesh);RangeAngleFFT_mesh=20*log10(RangeAngleFFT_mesh);
%         figure(6);
%         mesh(radar.rawA,radar.rawR,RangeAngleFFT_mesh);title("距离-角度FFT");ylabel("距离m");xlabel("角度/degree");zlabel("功率 dB")
%% 确定角度搜索范围及对应的尺度
theta_scan=1*linspace(-50,50,101);
array=0:1:radar.Na-1;
%% ********************************DBF**************************************** %%
%原理构造视场范围内的各个角度的导向矢量，
% 并用这些导向矢量分别去和阵列的回波信号相乘以得到各个角度下的能量值
% 我们通过寻找其中的极大值(目标所处方向的回波与导向矢量相干叠加，
% 这些方向的能量会得到增强，而噪声是非相干的，能量得到增强的方向，
% 对应极大值的位置，也即信号的方向)来得到实际回波的方向而达到测角的目的
%********************%
% 优点：快速和FFT一样？
% 缺点：角度分辨率和孔径有关
%********************%
 DBFpower_mesh=zeros(radar.chirpNum,length(theta_scan));
 DBFpower_Sum=zeros(length(theta_scan),1);
 for i=1:radar.chirpNum
     a_tehtaDBF=exp((1i*2*pi*0.5*sind(theta_scan(:))).*array);% 导向矢量 181*8
     temp=a_tehtaDBF*squeeze(data(:,i,:))';                    % 181*8*8*128=181*128 导向矢量与信号相乘得到能量
     temp=abs(temp);temp=temp/max(max(temp));
     temp=(sum(temp,2))/radar.sample_num;
     DBFpower_mesh(i,:)=temp;
     DBFpower_Sum=DBFpower_Sum+temp/radar.chirpNum;     
     DBFpower_mesh(i,:)=abs(DBFpower_mesh(i,:))/max(abs(DBFpower_mesh(i,:)));
 end
 DBFpower_mesh=abs(DBFpower_mesh);DBFpower_mesh=20*log10(DBFpower_mesh);
 DBFpower_Sum=abs(DBFpower_Sum)/max(abs(DBFpower_Sum));DBFpower_Sum=20*log10(DBFpower_Sum);
%      figure(7);
%      mesh(theta_scan,1:radar.chirpNum,DBFpower_mesh);title("角度多帧谱-DBF");ylabel("chirp num");xlabel("角度/degree");zlabel("功率 dB");

%% ********************************capon************************************** %%
%% 也是波束形成的一种区别在于导向矢量（权矢量）的不同
%********************************%
%缺点:需要多块拍以及高SNR
%优点：超分辨
%与DBF一样本质都是在找能量值最大
%********************************%
CaponPower_mesh=zeros(radar.chirpNum,length(theta_scan));       % 非积累
CaponPower_Sum=zeros(length(theta_scan),1);                     % chirp非相干积累
for i=1:radar.chirpNum
    signal=squeeze(data(:,i,:))';                               % 行为通道数 列数为采样数
    R=inv(signal*signal')/radar.sample_num;                     % 取均值
    a_tehtaCapon=exp((1i*2*pi*0.5*sind(theta_scan(:))).*array);  % 导向矢量 181*8
    temp=1./abs(a_tehtaCapon*R*a_tehtaCapon');
    temp=diag(temp);
    CaponPower_mesh(i,:)=(temp)/max((temp));
end
CaponPower_Sum=sum(CaponPower_mesh)/radar.chirpNum;
CaponPower_mesh=abs(CaponPower_mesh);CaponPower_mesh=20*log10(CaponPower_mesh);
CaponPower_Sum=abs(CaponPower_Sum)/max(abs(CaponPower_Sum));CaponPower_Sum=20*log10(CaponPower_Sum);
%     figure(8);
%     mesh(theta_scan,1:radar.chirpNum,CaponPower_mesh);title("角度多帧谱-Capon");ylabel("chirp num");xlabel("角度/degree");zlabel("功率 dB");
%% ********************************MUSIC************************************** %%
%********************************%
%缺点:需要多块拍以及高SNR 多一个信源个数
%优点：超分辨
%利用信号子空间与噪声子空间的正交性
%********************************%
MUSICpower_mesh=zeros(radar.chirpNum,length(theta_scan));
MUSICpower_Sum=zeros(length(theta_scan),1);
target_num=2;   % 这里假设有两个目标
for i=1:radar.chirpNum
    signal=squeeze(data(:,i,:))';  
    R=signal*signal'/radar.sample_num;      % 信号协方差 然后计算特征值 提取特征值
    [EigVec,Eig]=eig(R);                    % 返回的是特征值向量构成的矩阵和特征值作为对角元素构成的矩阵 因为是对矩阵的分解
    Eig=diag(Eig);                          % 提取主对角线上的特征值
    [~,index]=sort(Eig);                    % 默认升序排列，并返回对应的索引
    Q=EigVec(:,index(1:end-target_num));    % 得到对应噪声子空间的特征向量构成的矩阵
    a_thetaMusic=exp((1i*2*pi*0.5*sind(theta_scan(:))).*array);    % 导向矢量 181*8
    temp=abs(diag(a_thetaMusic*a_thetaMusic')./diag((a_thetaMusic*(Q*Q')*a_thetaMusic'))); % 得到的是一个矩阵 对角元素为想要的值
    temp=diag(temp)/max(diag(temp));
    MUSICpower_mesh(i,:)=temp;
end
MUSICpower_Sum=sum(MUSICpower_mesh)/radar.chirpNum;
MUSICpower_mesh=abs(MUSICpower_mesh);MUSICpower_mesh=20*log10(MUSICpower_mesh);
MUSICpower_Sum=abs(MUSICpower_Sum)/max(abs(MUSICpower_Sum));MUSICpower_Sum=20*log10(MUSICpower_Sum);
%     figure(9);
%     mesh(theta_scan,1:radar.chirpNum,MUSICpower_mesh);title("角度多帧谱-Music");ylabel("chirp num");xlabel("角度/degree");zlabel("功率 dB");
%% ********************************DML**************************************** %%

%% ********************************OMP**************************************** %%


%%
figure(10);
subplot(1,2,1);
plot(theta_scan,DBFpower_Sum,theta_scan,CaponPower_Sum,theta_scan,MUSICpower_Sum);
title("角度功率图");ylabel("功率/dB");xlabel("角度/degree");
legend(["DBF","Capon","MUSIC"]);
subplot(1,2,2);
imshow(radar.imag);
%pause(0.2);
Target=0;