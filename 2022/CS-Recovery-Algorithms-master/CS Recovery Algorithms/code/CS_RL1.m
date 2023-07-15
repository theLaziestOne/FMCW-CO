%% CS_RL1 Reweighted L1 Minimization Algorithm
% ���룺y---�����ź� M X 1
%          A---�ָ����� M X N
%          iter---����������  ���ٴ���2��С��2���൱��L1��С����û�м�Ȩ��

% �����ys---�ָ����ź� N X 1
%    
% 
%  minimize W||x||_1
%  subject to Ax=y
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��30��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף� Cand��s E J, Wakin M B, Boyd S P. 
% Enhancing sparsity by reweighted L1 minimization.[J]. 
% Journal of Fourier Analysis & Applications, 2007, 14(5):877-905.
%---------------------------------------------------------------------------------------------------------------------%
function xh=CS_RL1(y,A,iter)
N=max(size(A));
M=min(size(A));
Li=(M/(4*log(N/M)));
y=y(:);
W=ones(N,1);   %��ʼ��Ȩ������
QW=diag(W);    %��ʼ��Ȩ�ؾ���
% delta=0.01;
for i=1:iter
    QWt=inv(QW);
    At=A*QWt;
    x0=At'*y;  %��С���˽����һ����ʼֵ
    xh=l1eq_pd(x0,At,[],y,1e-3);
    delta=max(norm(xh,Li),1e-3) ;%��̬���� ����Ӧ����delta
%     delta should be set slightly smaller than the expected nonzero magnitudes of x0. 
%     In general, the recovery process tends to be reasonably robust to the choice of delta.--ԭ���еĻ�
    xh=QWt*xh;
    QW=diag(1./(abs(xh)+delta));
end

end
