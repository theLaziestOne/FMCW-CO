function w = root_music(sig,nn)
% 求根music，建议使用内建函数rootmusic（sig，nn）
% sig：输入信号
% nn：信源数量

[N,M] = size(sig);
Rx = sig' * sig / N;
[~,eigen_v] = my_eig(Rx);

D = conv(eigen_v(:,nn + 1),conj(flipud(eigen_v(:,nn + 1))));
for idx = nn + 2:M
    D = D + conv(eigen_v(:,idx),conj(flipud(eigen_v(:,idx))));
end
roots_D = roots(D);
roots_D1 = unique(roots_D(abs(roots_D) <= 1),'stable');

% Sort the roots from closest to furthest from the unit circle
[~,indx] = sort(abs(abs(roots_D1)-1));
sorted_roots = roots_D1(indx);
w = angle(sorted_roots(1:nn));
end

function [eigen, eigen_v, n] = my_eig(m)
[eigen_v, eigen] = eig(m);
[eigen, idx] = sort(diag(eigen),'descend');
eigen_v = eigen_v(:,idx);
end