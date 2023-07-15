function fft_plot(sig, radar, para)
% sig：输入信号
% radar：天线参数
% para：场景参数

%% 获取信号维度[天线数，快拍数，chirp数]
[N,K,C] = size(sig);
%% 对信号特定维度做傅里叶变换，将零频转移到中心，并取平均
sig_fft_c_A = fft_mean(sig,1);%距离FFT
sig_fft_c_D = fft_mean(sig,2);
sig_fft_c_S = fft_mean(sig,3);
%% 计算傅里叶变换后频率对应物理量
A_intervals = asin(radar.lambda * ((0:N - 1) - N / 2) / N / radar.d) / pi * 180;
D_intervals = radar.fs * ((0:K - 1) - K / 2) / K * para.c / (2 * radar.sweep_slope);
S_intervals = 1 / radar.tm * ((0:C - 1) - C / 2) / C / 2 * radar.lambda;
%% 画图
figure_plot(A_intervals,sig_fft_c_A,D_intervals,sig_fft_c_D,S_intervals,sig_fft_c_S,"FFT")
end

function sig_fft_c = fft_mean(sig, dim)
[len(1),len(2),len(3)] = size(sig);
if dim == 1
    I = 3;
    J = 2;
    K = 1;
elseif dim == 2
    I = 3;
    J = 1;
    K = 2;
elseif dim == 3
    I = 1;
    J = 2;
    K = 3;
end
sig_fft_c = cell(len(I),1);
for i = 1:len(I)
    sig_fft = zeros(len(K),1);
    for j = 1:len(J)
        if dim == 1
            sig_ = sig(:,j,i);
        elseif dim == 2
            sig_ = sig(j,:,i);
        elseif dim == 3
            sig_ = sig(i,j,:);
        end
        sig_ = reshape(sig_,length(sig_),1);
        sig_fft_ = fft(sig_);
        sig_fft = sig_fft + abs(sig_fft_/length(sig_fft_));
    end
%     sig_fft_c{i} = fftshift(sig_fft / len(J));
      sig_fft_c{i} = (sig_fft / len(J));

end
end
