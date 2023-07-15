%% CS_RL1_test
%------------------------------------------------------------------------------------------%
% The weighted L1 minimization can be viewed as a relaxation of a weighted L0 minimization problem
%  minimize W||x||_0
%  subject to Ax=y
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��05��3��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%------------------------------------------------------------------------------------------%
clc;clear all;close all
%% 1. ����ϡ����ź�
N=1024;
K=50;
x=zeros(N,1);
rand('state',8)
q=randperm(N); %�������1��N������
randn('state',10)
x(q(1:K))=randn(K,1); %��K�����������ŵ�x��
t=0:N-1;
%% 2. �����֪����
% M=2*ceil(K*log(N/K));
M=152;
Phi=randn(M,N);  %��˹������Ϊ��֪����
Phi=orth(Phi')';  %������

%% 3. �����ź�
y=Phi*x;
A=Phi;%�ָ�����,ϡ�軯����Ϊ��λ������Ϊ�źű������ϡ��ģ�����Ҫ���κ�ϡ��任
%% CS_RL1    ��ȨL1��С�����൱��L0��С��
[theta]=CS_RL1( y,A,1);
figure
subplot(3,1,1)
scatter(x,theta)
hold on
plot([min(x):0.01:max(x)],[min(x):0.01:max(x)],'r')
hold off
[theta]=CS_RL1( y,A,2);
subplot(3,1,2)
scatter(x,theta)
hold on
plot([min(x):0.01:max(x)],[min(x):0.01:max(x)],'r')
hold off

[theta]=CS_RL1( y,A,5);
subplot(3,1,3)
scatter(x,theta)
hold on
plot([min(x):0.01:max(x)],[min(x):0.01:max(x)],'r')
hold off
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('RL1�ָ��ź�','ԭʼ�ź�')