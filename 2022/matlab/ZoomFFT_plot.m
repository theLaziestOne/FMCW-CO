function ZoomFFT_plot(sig, radar, para)
% sig：输入信号
% radar：天线参数
% para：场景参数
% 角度上有点问题

%% 获取信号维度[天线数，快拍数，chirp数]
[N,K,C] = size(sig);
%% 对信号特定维度做傅里叶变换，获取感兴趣频率（只写了一个）
A_fe = freq_extract(reshape(sig(:,1,1),N,1),1,1);
D_fe = freq_extract(reshape(sig(1,:,1),K,1),radar.fs,1);
S_fe = freq_extract(reshape(sig(1,1,:),C,1),1 / radar.tm,1);
%% 对感兴趣频带做ZoomFFT
A_zfft{1} = zfft(reshape(sig(:,1,1),N,1),A_fe,1,2);
D_zfft{1} = zfft(reshape(sig(1,:,1),K,1),D_fe,radar.fs,16);
S_zfft{1} = zfft(reshape(sig(1,1,:),C,1),S_fe,1 / radar.tm,ceil(C/4));
%% 计算ZoomFFT后频率对应物理量
A_fz = A_fe - 1/2/2 + (0:N - 1)*1/2/N;
A_intervals = asin(radar.lambda * A_fz / radar.d) / pi * 180;
D_fz = D_fe - radar.fs/16/2 + (0:K - 1)*radar.fs/16/K;
D_intervals = D_fz * para.c / (2 * radar.sweep_slope);
S_fz = S_fe - 1 / radar.tm/ceil(C/4)/2 + (0:C - 1)*1 / radar.tm/ceil(C/4)/C;
S_intervals = radar.lambda * S_fz / 2;
%% 画图
figure_plot(A_intervals,A_zfft,D_intervals,D_zfft,S_intervals,S_zfft,"ZoomFFT")
end

function fe = freq_extract(X,fs,nn)
% X：输入信号
% fs：采样频率
% nn：信源数目

X_fft = fft(X);
X_fft = X_fft(1:floor(length(X_fft)/2)+1);
X_fft(2:end-1) = 2*X_fft(2:end-1);
f = fs*(0:floor(length(X)/2))/length(X);
[~, fe_idx] = sort(abs(X_fft),'descend');
fe = f(fe_idx(1:nn));
end

function X_zfft = zfft(X,fe,fs,D)
% X：输入信号
% fe：待细化中心频率
% fs：采样频率
% D：细化倍数（X长度必须为D的倍数）

object_zfft = dsp.ZoomFFT(D,fe,fs,'FFTLength',length(X));
X_zfft = fftshift(object_zfft(X));
end
