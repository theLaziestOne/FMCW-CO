% ------ 程序功能：四类CFAR检测算法的检测概率与SNR的关系 %
clc
clear all;
close all;

%% 参数设置
R = 24;                     % 参考单元长度
n = R/2;                    % 半滑窗长度
k = R*3/4;                  % os-cfar的参数
P_fa = 1e-6;                % 虚警概率
SNR_dB = (0:30);            % 信噪比
SNR = 10.^(SNR_dB./10);     % 信号功率与噪声功率的比值
syms T;                     % 门限因子的符号变量
%% CA-CFAR
T_CA = P_fa^(-1/R)-1;           % CA-CFAR的门限因子
Pd_CA = (1+T_CA./(1+SNR)).^(-R);    % CA-CFAR的检测概率

%% SO-CFAR、GO-CFAR
Pfa_SO = 0;
syms T
for i = 0:n-1
    Pfa_SO = Pfa_SO+2*nchoosek(n+i-1,i)*(2+T)^(-(n+i));     % SO-CFAR的虚警概率表达式
end
T1_SO = solve(Pfa_SO == P_fa, T);       % 求解出虚警概率为P_fa时对应的门限因子T
T2_SO = double(T1_SO);
T_SO = T2_SO(T2_SO == abs(T2_SO));      % SO-CFAR的门限因子

Pfa_GO = 2*(1+T)^(-n)-Pfa_SO;           % GO-CFAR的虚警概率表达式
T1_GO = solve(Pfa_GO == P_fa, T);       % 求解出虚警概率为P_fa时对应的门限因子T
T2_GO = double(T1_GO);
T_GO = T2_GO(T2_GO == abs(T2_GO));      % GO-CFAR的门限因子

Pd_SO = 0;
Pd_GO = 0;
for j = 0:n-1
    Pd_SO = Pd_SO+2*nchoosek(n+j-1,j).*(2+T_SO./(1+SNR)).^(-(n+j));     % SO-CFAR的检测概率
    Pd_GO = Pd_GO+2*nchoosek(n+j-1,j).*(2+T_GO./(1+SNR)).^(-(n+j));
end
Pd_GO = 2.*(1+T_GO./(1+SNR)).^(-n)-Pd_GO;         % GO-CFAR的检测概率

%% OS-CFAR
Pfa_OS = k*nchoosek(R,k)*gamma(R-k+1-T)*gamma(k)/gamma(R+T+1);           % OS-CFAR的虚警概率表达式
T1_OS = solve(Pfa_OS == P_fa, T);       % 求解出虚警概率为P_fa时对应的门限因子T
T2_OS = double(T1_OS);
T_OS = T2_OS(T2_OS == abs(T2_OS));      % OS-CFAR的门限因子
Pd_OS = k*nchoosek(R,k)*gamma(R-k+1-T_OS./(1+SNR))*gamma(k)./gamma(R+T_OS./(1+SNR)+1);      % OS-CFAR的检测概率

%% 画图
figure;
plot(SNR_dB,Pd_CA,'r-*');
hold on;
plot(SNR_dB,Pd_SO,'k-^');
plot(SNR_dB,Pd_GO,'b-o');
plot(SNR_dB,Pd_OS,'m-.');
grid on;
xlabel('SNR','FontName','Time New Romans','FontAngle','italic');
ylabel('P_{d}','FontName','Time New Romans','FontAngle','italic');
title(['恒虚警率 P_{fa}= ',num2str(P_fa),'，参考单元 2n= ',num2str(R)]);
legend('CA','SO','GO','OS');

