function P = music(x, nn, Phis)
% x：输入信号
% nn：信源数量
% Phis：待搜索频率集

[N,M] = size(x);
Rx = x' * x / N; % 自相关矩阵
[eigen_v,~] = eig(Rx); % 升序特征值对应的特征向量
eigen_v = flip(eigen_v, 2); % 降序特征值对应的特征向量
a_theta = exp(-1i * (0:M-1)' * Phis); % 信号频率向量
G = eigen_v(:,nn + 1:M);
P = 1 ./ diag((a_theta' * (G * G') * a_theta)); % 伪谱计算
end