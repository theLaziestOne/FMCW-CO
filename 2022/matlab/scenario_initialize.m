function [radar,target,channel,specanalyzer] = scenario_initialize(para)
% 仿真场景初始化
radar = radar_parameter_set(para);                              % 雷达车辆
target = target_parameter_set(para,radar);                      % 目标车辆
channel = phased.FreeSpace('PropagationSpeed',para.c,'OperatingFrequency',...
    radar.fc,'SampleRate',radar.fs,'TwoWayPropagation',true);   % Space
specanalyzer = spectrumAnalyzer('SampleRate',radar.fs, ...
    'Method','welch','AveragingMethod','running', ...
    'PlotAsTwoSidedSpectrum',true, 'FrequencyResolutionMethod','rbw', ...
    'Title','Spectrum for received and dechirped signal', ...
    'ShowLegend',true);                                         % 频谱分析器
end

function radar = radar_parameter_set(para)
radar.v_max = 230*1000/3600;              % 最大检测速率
radar.range_max = 200;                    % 最大检测距离
radar.fc = 77e9;                          % 基础频率
radar.range_res = 1;                      % 距离分辨率

lambda = para.c/radar.fc;                      % 波长
t_retrace = range2time(radar.range_max,para.c);% 最大距离系下毫米波往反耗时
radar.tm = 5.5 * t_retrace;               % 扫描周期（5-6倍往反耗时）

radar.bw = rangeres2bw(radar.range_res,para.c);      % 带宽
radar.sweep_slope = radar.bw/radar.tm;                % 斜率

radar.fr_max = range2beat(radar.range_max,radar.sweep_slope,para.c);   % 最大距离拍频
radar.fd_max = speed2dop(2*radar.v_max,lambda);             % 最大速率拍频
radar.fb_max = radar.fr_max+radar.fd_max;                         % 最大拍频

radar.fs = max(2*radar.fb_max,radar.bw);              % 采样频率
radar.lambda = para.c/radar.fc;
radar.speed = 100*1000/3600;

radar.ant_aperture = 6.06e-4;                         % in square meter
radar.ant_gain = aperture2gain(radar.ant_aperture,radar.lambda);  % in dB

radar.tx_ppower = db2pow(5)*1e-3;                     % in watts
radar.tx_gain = 9+radar.ant_gain;                           % in dB

radar.rx_gain = 15+radar.ant_gain;                          % in dB
radar.rx_nf = 4.5;                                    % in dB

radar.radarmotion = phased.Platform('InitialPosition',[0;0;0.5],...
    'Velocity',[radar.speed;0;0]);
radar.waveform = phased.FMCWWaveform('SweepTime',radar.tm,'SweepBandwidth',radar.bw, ...
    'SampleRate',radar.fs,'NumSweeps',1);
radar.transmitter = phased.Transmitter('PeakPower',radar.tx_ppower,'Gain',radar.tx_gain);
radar.receiver = phased.ReceiverPreamp('Gain',radar.rx_gain,'NoiseFigure',radar.rx_nf,...
    'SampleRate',radar.fs);
end

function car = target_parameter_set(para,radar)
car.car_dist = 43; % 目标距离
car.car_speed = 96*1000/3600; % 目标速度
car.car_rcs = db2pow(min(10*log10(car.car_dist)+5,20)); % 目标RCS
car.cartarget = phased.RadarTarget('MeanRCS',car.car_rcs,'PropagationSpeed',para.c,...
    'OperatingFrequency',radar.fc); % 创建被检测目标
car.carmotion = phased.Platform('InitialPosition',[car.car_dist;0;0.5],...
    'Velocity',[car.car_speed;0;0]); % 创建目标运动
end
