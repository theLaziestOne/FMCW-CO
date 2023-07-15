

%%
%----------------------------------------------------------------------------------%
%  1-D�ź�ѹ�����е�ʵ��(l1-MAGIC��l1_ls��l1����)     �źű������ϡ��ģ�
%  ����Ҫϡ����󣬻ָ�����A�ǵ�λ����������OMP�������l1����.
%  ������M>=K*log(N/K),K��ϡ���,N�źų���,���Խ�����ȫ�ع�
%  �����--���Ͻ�ͨ��ѧǣ�����������ص�ʵ���� ����  Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��27��
%---------------------------------------------------------------------------------%
clc;clear all;close all;
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
M=2*ceil(K*log(N/K));
Phi=randn(M,N);  %��˹������Ϊ��֪����
Phi=orth(Phi')';  %������

%% 3. �����ź�
y=Phi*x;
A=Phi;%�ָ�����,ϡ�軯����Ϊ��λ������Ϊ�źű������ϡ��ģ�����Ҫ���κ�ϡ��任
%% 4. �ع��ź� l1��С��   Using  l1-MAGIC  �÷����ָ��Ϻ� ģ��ƥ��min_x ||x||_1  s.t.  Ax = b
x0=A'*y;  %��С���˽����һ����ʼֵ
xh1=l1eq_pd(x0,A,[],y,1e-3);

%% 5. �ع��ź�l1��С��   Using l1_ls �÷�����΢��� ģ��Ϊ minimize ||A*x-y||^2 + lambda*sum|x_i|,
lambda  = 0.01; % ���򻯲���
rel_tol = 1e-3; % Ŀ����Զ�ż��϶
quiet=1;   %������м���
[xh2,status]=l1_ls(A,y,lambda,rel_tol,quiet);

%% 6. �ָ��źź�ԭʼ�źűȽ� 
figure
plot(t,xh1,'ko',t,x,'r.')
xlim([0,t(end)])
legend('l1-MAGIC�ָ��ź�','ԭʼ�ź�')

figure
plot(t,xh2,'ko',t,x,'r.')
xlim([0,t(end)])
legend('l1-ls�ָ��ź�','ԭʼ�ź�')

%% 7. ������ƥ��׷�ٵķ�������l1���Ż�����
[ xh,erro_rn ] = CS_OMP( y,A,2*K );
figure
plot(erro_rn,'-*')
legend('OMP����ƥ��׷�����')
figure
plot(t,xh,'ko',t,x,'r.')
xlim([0,t(end)])
legend('OMP�ָ��ź�','ԭʼ�ź�')

%% 8. ��ѹ������ƥ��׷��(CoSaMP)�ķ�������l1���Ż�����
%Needell D, Tropp J A. CoSaMP: Iterative signal recovery from incomplete 
% and inaccurate samples [J]. Applied & Computational Harmonic Analysis, 2008, 26(3):301-321.
% һ����ѡ��2*K���ϴ�Ļ���ÿ��ѭ������ɾ���Ͳ���һ����Ŀ�Ļ������ﵽ��������

A=Phi;    %�ָ�����

%% CoSaMP
 [theta,erro_rnn]=CS_CoSaMP( y,A,K );
 figure
plot(erro_rnn,'-*')
legend('CoSaMPѹ������׷�����')
 %%    
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('CoSaMP�ָ��ź�','ԭʼ�ź�')

%% CS_NSRAL0
A=Phi;    %�ָ����� 
deltaT=1e-3;
r=1/3;
te=0.01;
eps=0.09;
[theta,Spare_L0]=CS_NSRAL0(y,A,deltaT,r,te,eps);
figure
plot(1:length(Spare_L0),Spare_L0,'b*-',1:length(Spare_L0),ones(length(Spare_L0),1)*K,'r^-')
legend('����L0����׷�ٽ��','��ʵϡ���')
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('NSRAL0�ָ��ź�','ԭʼ�ź�')

%% CS_SL0
A=Phi;    %�ָ����� 
[theta,Spare_L0]=CS_SL0( y,A,0.001,0.9,2,3);
figure
plot(1:length(Spare_L0),Spare_L0,'b*-',1:length(Spare_L0),ones(length(Spare_L0),1)*K,'r^-')
legend('����L0����׷�ٽ��','��ʵϡ���')
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('SL0�ָ��ź�','ԭʼ�ź�')

%% CS_UALP
A=Phi;    %�ָ����� 
[theta]=CS_UALP( y,A,0.1);
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('UALP�ָ��ź�','ԭʼ�ź�')

%% CS_RSL0
A=Phi;    %�ָ����� 
[theta,Spare_L0]=CS_RSL0( y,A,0.001,0.9,2,3,0.001);
figure
plot(1:length(Spare_L0),Spare_L0,'b*-',1:length(Spare_L0),ones(length(Spare_L0),1)*K,'r^-')
legend('����L0����׷�ٽ��','��ʵϡ���')
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('RSL0�ָ��ź�','ԭʼ�ź�')


%% CS_IRLS
A=Phi;    %�ָ����� 
[theta]=CS_IRLS( y,A,0,1e-8,0.1);
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('IRLS�ָ��ź�','ԭʼ�ź�')

%% CS_RL1    ��ȨL1��С�����൱��L0��С��
A=Phi;    %�ָ����� 

[theta]=CS_RL1( y,A,3);
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('RL1�ָ��ź�','ԭʼ�ź�')

%% CS_IHT    ��ȨL1��С�����൱��L0��С��
A=Phi;    %�ָ����� 

% [theta]=CS_IHT( y,A,K);
[theta]=CS_IHT( y,A);
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('IHT�ָ��ź�','ԭʼ�ź�')


%% CS_SBI    
A=Phi;    %�ָ����� 

theta=CS_SBIL1(y,A,2000,100,1e4)
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('SBIL1�ָ��ź�','ԭʼ�ź�')

%% ISTA
A=Phi;    %�ָ�����  
[theta,erro_rnn]=CS_ISTA( y,A,0.00819); %0.00819
figure
plot(erro_rnn,'-*')
legend('ISTA���')
%% �ָ��źź�ԭʼ�źűȽ�
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('ISTA�ָ��ź�','ԭʼ�ź�')

%% FISTA
A=Phi;    %�ָ�����  
[theta,erro_rnn]=CS_ISTA( y,A,0.00819); %0.00819
figure
plot(erro_rnn,'-*')
legend('FISTA���')
%% �ָ��źź�ԭʼ�źűȽ�
figure
plot(t,theta,'ko',t,x,'r.')
xlim([0,t(end)])
legend('FISTA�ָ��ź�','ԭʼ�ź�')





