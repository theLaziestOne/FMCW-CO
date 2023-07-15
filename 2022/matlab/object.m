clear
clc
close all
rng('default');

%% 参数设置
para.c = 3e8;               % 光速
para.external_data = 3;     % 外部数据输入（1-4）(0使用仿真数据)

%% 仿真数据生成
if ~para.external_data
    para.Nsweep = 32;       % 扫描周期数
    [radar,target,channel,specanalyzer] = scenario_initialize(para);
    sig = gen_signal(para,radar,target,channel);
    radar.d = 0;
end

%% 外部数据读入
if para.external_data
    para.filename = ['..\2022A\data_q' num2str(para.external_data) '.mat'];
    [sig, radar] = load_signal(para);
end

%% 数据处理
fft_plot(sig, radar, para)
music_plot(sig, 2, radar, para)
%  SuperResolutionCS_plot(sig, 2, radar, para)