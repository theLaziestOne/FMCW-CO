function music_plot(sig, nn, radar, para)
% sig：输入信号
% nn：信源数量
% radar：天线参数
% para：场景参数

%% 获取信号维度[天线数，快拍数，chirp数]
[N,K,C] = size(sig);
%% 设置超分辨范围和分辨率 (由FFT快速给定)
if para.external_data == 0
    %% 仿真数据1
    A_intervals = 0; % 度
    S_intervals = -9:0.1:9; % m/s
    D_intervals = 42:0.1:44; % m
elseif para.external_data == 1
    %% 外部数据1
    A_intervals = -2:0.001:2; % 度
    S_intervals = 0; % m/s
    D_intervals = 6.9:0.001:7.1; % m
elseif para.external_data == 2
    %% 外部数据2
    A_intervals = -3:0.001:3; % 度
    S_intervals = 0; % m/s
    D_intervals = 6.8:0.001:7.1; % m
elseif para.external_data == 3
    %% 外部数据3
    % 对每一个chirp分别给定范围和分辨率会快很多
    A_intervals = -10:0.05:10; % 度
    S_intervals = [-30:0.1:-7 7:0.1:30]; % m/s
    D_intervals = 5.4:0.005:6.6; % m
elseif para.external_data == 4
    %% 外部数据4
    A_intervals = -1.4:0.001:1.4; % 度
    S_intervals = 0; % m/s
    D_intervals = 5.9:0.001:6.2; % m
end
%% 转换到对应[-pi，pi]频率
A_Phis = sin(A_intervals * pi / 180) * radar.d/ radar.lambda *  2 * pi;
S_Phis = S_intervals * 2 * radar.tm / radar.lambda *  2 * pi;
D_Phis = D_intervals/ radar.fs / para.c * 2 * radar.sweep_slope *  2 * pi;
%% 对每一个chirp求角度和距离
Angle{1} = 0;
Distance{1} = 0;
for c = 1:C
    if N > 1
        Angle{c} = music(sig(:,:,c).', nn, A_Phis);
    end
    if K > 1
        Distance{c} = music(sig(:,:,c), nn, D_Phis);
    end
end
%% 对每个固定拍求一帧速度（假定一帧内目标匀速运动）
Speed{1} = 0;
if  C > 1
    if N > 1
    for k = 1:K
        X = sig(:,k,:);
        X = reshape(X,N,C);
        Speed{k} = music(X, nn, S_Phis);
    end
    elseif K > 1
    for n = 1:N
        X = sig(n,:,:);
        X = reshape(X,K,C);
        Speed{n} = music(X, nn, S_Phis);
    end
    end
end
%% 画图
figure_plot(A_intervals,Angle,D_intervals,Distance,S_intervals,Speed,"MUSIC")
end