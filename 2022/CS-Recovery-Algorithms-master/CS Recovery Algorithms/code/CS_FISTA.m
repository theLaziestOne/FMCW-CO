%% Fast Iterative Shrinkage-Thresholding Algorithm    (FISTA)
%%  A Proximal-Gradient Algorithm Method
%-----------------------------------------------------------------------------------------%
%  CS_FISTA  Algorithm (���ٵ���������ֵ�㷨 FISTA)   
%  ���룺y---�����ź�  M X 1
%           A---�ָ�����  M X N
%           lambda---���򻯲���     
%           iter---����������
% ��� ��xhk---���Ƶ�ϡ������ N X 1
%            erro---ÿ�ε��������
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף�A. Beck and M. Teboulle,
% ��A fast iterative shrinkage-thresholding algorithm for linear inverse
% problems,�� SIAM J. Imaging Sciences, vol. 2, no. 1, pp. 183-202, 2009.
%------------------------------------------------------------------------------------------%
%                                   �㷨��ϸ����---ISTA
%  minimize ||A*x-y||^2 + lambda*||x||_1     (1)
%  ||A*x-y||^2�Ƕ�����ƽ��
%  f(x)= ||A*x-y||^2=x'A'Ax-2x'A'y+y'y
%  һ�׵���Ϊ����f(x)= 2A'Ax-2A'y=2A'(Ax-y)

% (1)����С������ת��Ϊ x_k=argmin{(1/(2*t_k))||x-(x_k-t_k��f(x_k-1))||^2+lambda||x||_1}
% �ȼ�Ϊx_k=argmin{(1/(2*t_k))||x-c_k||^2+lambda||x||_1}
% ����c_k=x_k-t_k��f(x_k-1)=x_k-1-2t_kA'(Ax_k-1-y)

% t_kΪ��ⲽ��
%% �㷨ʵ��
% ���룺 ��f(x)�о���A��Lipschitz����L=L(f)
% ��һ���� y1=x_0(n X 1),t_1=1
% ��k����(k>1) ����
%            (1) x_k=P_L(y_k)  �����⣺x_k=argmin{(1/(2*t_k))||x-(x_k-t_k��f(x_k-1))||^2+lambda||x||_1}
%            (2) t_(k+1)=(1+sqrt(1+4*(t_k)^2))/2
%            (3) y_(k+1)=x_k+((t_k-1)/t_(k+1))*(x_k-x_(k-1))
%%

% F(x_k)-F(x*)<=2*L(f)||x_0-x*||^2/(k+1)^2
%�����ٶ�1/k^2

%%
function [xhk,err]=CS_FISTA(y,A,lambda,iter)
if nargin<4;
    iter=1e6;  %�㹻��ֱ���ܴﵽ����1e-6
end
y=y(:);
N=max(size(A));
M=min(size(A));

% Li=1/max(eig(A*A'));   %���Lipschitz����   1/||A'A||  �Ƚ�����ʱ��

%-------------------------------------------%
% ��power�������������ֵ
%
Mat=A*A';
x=randn(M,1);
for i=1:5;  %һ��3-5�ξͿ�����
    x=x/norm(x,2); %��һ��
    x=Mat*x;
end
x=x/norm(x,2);
Lf=x'*Mat*x;
Li=1/Lf;
%-------------------------------------------%

tk=1;  
xhk=zeros(N,1);  %��ʼ���洢��������ʼ������ֵ��0��ʼ �൱��x_k��
yk=xhk;    %��ʼ����������y
% xhk=A'*y;       %���Թ���һ����С����ֵ���Ӹ�ֵ��ʼ����
alp=lambda*Li;  %����alp=lambda*Li
err(1)=0;
for i=1:iter;
     ck=yk-2*Li*A'*(A*yk-y);  %����c_k
     xhk1=(max(abs(ck)-alp,0)).*sign(ck);  %����x_k,�����´ε���
     tk1=0.5+0.5*sqrt(1+4*tk^2);
     tt=(tk-1)/tk1;
     yk=xhk1-tt*(xhk1-xhk);
     tk=tk1;
     xhk=xhk1;
     err(i+1)=norm(A*xhk-y,2);
     if abs(err(i+1)-err(i))<1e-6;  %����ѭ��
        err=err(2:end);
        break;
     end
end
err=err(2:end);        
end