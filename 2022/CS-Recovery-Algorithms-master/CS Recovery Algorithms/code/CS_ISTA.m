%% Iterative Shrinkage-Thresholding Algorithm    (ISTA)
%----------------------- A Proximal-Gradient Algorithm Method-------------------------%
%  CS_ISTA  Algorithm (����������ֵ�㷨 ISTA)   
%  ���룺y---�����ź�  M X 1
%           A---�ָ�����  M X N
%           lambda---���򻯲���     
%           iter---����������
% ��� ��xhk---���Ƶ�ϡ������ N X 1
%            err---ÿ�ε��������
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף�I. Daubechies, M. Defrise, and C. D. Mol,
% ��An iterative thresholding algorithm for linear inverse problems with a sparsity constraint,�� 
% Comm. Pure Appl. Math., vol. 57, pp. 1413-1457, 2004.
%------------------------------------------------------------------------------------------%
%  minimize ||A*x-y||^2 + lambda*||x||_1     (1)
%  ||A*x-y||^2�Ƕ�����ƽ��
%  f(x)= ||A*x-y||^2=x'A'Ax-2x'A'y+y'y
%  һ�׵���Ϊ����f(x)= 2A'Ax-2A'y=2A'(Ax-y)

% (1)����С������ת��Ϊ x_k=argmin{(1/(2*t_k))||x-(x_k-t_k��f(x_k-1))||^2+lambda||x||_1}
% �ȼ�Ϊx_k=argmin{(1/(2*t_k))||x-c_k||^2+lambda||x||_1}
% ����c_k=x_k-t_k��f(x_k-1)=x_k-1-2t_kA'(Ax_k-1-y)

% t_kΪ��ⲽ��
%%
%t_k=1/L(f)  Lipschitz�����ĵ���
% �㷨ʵ��,c_k,t_k,lambda,alp=lambda*t_k; t_k=[0,1/||A'A||]
% x_k=max(abs(c_k)-alp,0).*sign(c_k)
%%

% F(x_k)-F(x*)<=L(f)||x_0-x*||^2/2*k
%�����ٶ�1/k

%%
function [xhk,err]=CS_ISTA(y,A,lambda,iter)
if nargin<4;
    iter=1e6;  %�㹻��ֱ���ܴﵽ����1e-6
end
y=y(:);
N=max(size(A));
M=min(size(A));
% tmax=1/max(eig(A*A'));   %���Lipschitz����   1/||A'A||
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
tmax=1/Lf;
%-------------------------------------------%

tk=0.95*tmax;  %�Ͻ���΢��Сһ��
xhk=zeros(N,1);  %��ʼ���洢��������ʼ������ֵ��0��ʼ �൱��x_k��
% xhk=A'*y;       %���Թ���һ����С����ֵ���Ӹ�ֵ��ʼ����
alp=lambda*tk;  %����alp=lambda*t_k
err(1)=0;
for i=1:iter;
     ck=xhk-2*tk*A'*(A*xhk-y);  %����c_k
     xhk=(max(abs(ck)-alp,0)).*sign(ck);  %����x_k,�����´ε���
     err(i+1)=norm(A*xhk-y,2);
     if abs(err(i+1)-err(i))<1e-6;  %����ѭ��
         err=err(2:end);
         break;
     end
end
err=err(2:end);       
end