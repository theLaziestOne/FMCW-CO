function SuperResolutionCS_plot(sig, nn, radar, para)
% sig：输入信号
% nn：信源数量
% radar：天线参数
% para：场景参数

%% 对sig每个维度进行压缩感知，并取平均
A_f = SuperResolutionCS_mean(sig, 1, nn);
D_f = SuperResolutionCS_mean(sig, 2, nn);
S_f = SuperResolutionCS_mean(sig, 3, nn);
%% 由频率计算物理量



end

function f = SuperResolutionCS_mean(sig, dim, nn)
[len(1),len(2),len(3)] = size(sig);
if dim == 1
    I = 3;
    J = 2;
elseif dim == 2
    I = 3;
    J = 1;
elseif dim == 3
    I = 1;
    J = 2;
end
f = cell(len(I),1);
for i = 1:len(I)
    f_{i} = 0;
    for j = 1:len(J)
        if dim == 1
            sig_ = sig(:,j,i);
        elseif dim == 2
            sig_ = sig(j,:,i);
        elseif dim == 3
            sig_ = sig(i,j,:);
        end
        sig_ = reshape(sig_,length(sig_),1);
        N = length(sig_);
        M = ceil(nn * log(N / nn));
        Phi = zeros(M,N);
        for ii = 1:M
            Phi(ii,ceil(rand * N)) = 1;
        end
        y = Phi * sig_;
        [~,~,f_tmp] = SIHT(y, Phi, nn, N);
        f_{i} = f_{i} + f_tmp;
    end
    f_{i} = f_{i} / len(J);
end
end

%% 迭代硬决策算法（有问题）
function [x,c,w] = SIHT(y, Phi, nn, L, sigma, loopmax)
if nargin < 6
    loopmax = 3e3;
end
if nargin < 5
    sigma = 1e-3;
end
i = 0;
M = size(Phi,1);
x = zeros(L,1);
L = (1:L)';
while norm(y - Phi * x) >= sigma && i < loopmax
    x = x + Phi' * (y - Phi * x);
    w = rootmusic(x, nn);
    SparseM_ = exp(-1i * L * (-w)');
    SparseM = exp(-1i * L * w');
    c = SparseM_.' * x / M;
    x = SparseM * c;
    i = i + 1;
end
end
