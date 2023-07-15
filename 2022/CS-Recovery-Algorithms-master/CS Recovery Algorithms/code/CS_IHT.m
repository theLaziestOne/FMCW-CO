%% CS_IHT  Iterative Hard Thresholding algorithms for compressive sensing
% ���룺y---�����ź� M X 1
%          A---�ָ����� M X N
%          K---�źŵ�ϡ���
% �����x0---�ָ����ź� N X 1
%    
% 
%  minimize ||x||_1
%  subject to ||Ax-y||_2<eps
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��30��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף�Blumensath T, Davies M E. 
% Iterative hard thresholding for compressed sensing[J]. 
% Applied & Computational Harmonic Analysis, 2009, 27(3):265-274.
% Blumensath T, Davies M E.
% Iterative Thresholding for Sparse Approximations[J].
% Journal of Fourier Analysis and Applications, 2008, 14(5):629-654.
%---------------------------------------------------------------------------------------------------------------------%

function x0=CS_IHT(y,A,K)

M=min(size(A));
N=max(size(A));
if nargin<3;
    K=floor(M/4);        %���ٵ���������һ�����ϡ����������鹫ʽ����4��Ϊ��֤�ع����ȣ�iter����ѡ��һ��
end
x0=zeros(N,1);         % ��ʼ����ռ�����
u=0.5;                       % Ӱ��ϵ��

for times=1:M
    
    x1=A'*(y-A*x0);
    
    x2=x0+u*x1;
    
    [val,pos]=sort(abs(x2),'descend');  % ��������
    
    x2(pos(K+1:end))=0;   % ��������ǰiters���������ݣ�itersΪϡ���

    x0=x2;          % ����ֵ����һ��ѭ��

end
