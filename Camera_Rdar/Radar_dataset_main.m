%% 这个文件用来处理毫米波数据
%%CTAR TEST
clear all;
clc;
close all;

%% 傅里叶点数
addpath('C:\Users\user\Desktop\毫米波+相机\Automotive\2019_04_09_bms1000\radar_raw_frame');
addpath('C:\Users\user\Desktop\毫米波+相机\Automotive\2019_04_09_bms1000\images_0');
radar=radarPrameters();
for frame =3:radar.frameNum % 帧数设置
    adcData = load([num2str(frame, '%06d'),'.mat']).adcData;
    Image=imread([num2str(frame-3, '%010d'),'.jpg']);
    radar.imag=Image;
    %% 设定对应的为量测信息以位置作为列的形式给出 并额外提供多普勒信息
    [measurement]=ProcessForFMCWdata(adcData,radar);
    
    %% 里面
%     if frame==3
% %         target=KalmanFiletr(measurement,frame-2,radar);
% %     else
% %         target=KalmanFiletr(measurement,frame-2,radar,target);
%     end
%     
end

