clc;clear all;close all;
%%
%----------------------------------------------------------------------------------%
%  1-D�ź�ѹ�����е�ʵ��(l1-MAGIC��l1_ls��l1����)   
%  ������M>=K*log(N/K),K��ϡ���,N�źų���,���Խ�����ȫ�ع�
%  �����--���Ͻ�ͨ��ѧǣ�����������ص�ʵ���� ����  Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��
%---------------------------------------------------------------------------------%
%% 1. �����ź�
fs=100;     %����Ƶ��
N=100;    %�źų���
t=0:1/fs:(N-1)/fs; 
x2=cos(2*pi*50*t);  %�����ź�
%% 2. ��ɢ���ұ任��������Сֵ����Ϊ0��ȷ��ϡ��ȣ����ع����ź�
% C=gen_dct(N);
C=dctmtx(N);     %��ɢ���ұ任����
cx=C*x2';
cx(find(abs(cx)<0.5))=0;   %����С�������㣬��ȻӰ��ԭʼ�źţ���ȷ����ϡ���
% figure
% plot([x2',C'*cx])
x2=C'*cx;    %�ع����źţ����źŵ���ɢ���ұض�ϡ��
x2=x2';
%% 3. �����ź�   
% ��44�����źŵ����ݻָ�100��������ݣ������ο�˹��Nyquist��������1s�����100������ָܻ�ԭʼ�źţ�
% ����CS����ֻ��Ҫ44��������ݾ��ָܻ�������ȫͻ����Nyquist������������ơ�

K=length(find(abs(cx)>0.5));   %�ź�ϡ���,�鿴��ɢ���ұ任��ͼ
M=2*ceil(K*log(N/K)); %K=9�ǣ���ֵΪ22��������,��������ѹ���̶ȣ����鹫ʽ
randn('state',4)
Phi=randn(M,N);  %  ��������(��˹�ֲ�������)
Phi=orth(Phi')';    %������
y=Phi*x2.';     %  ������Բ��� ---ֻ��44���㣬

%% 4. l1������С�� l1-Magic������ 
% l1eq_pd������������������Ż�����
% min_x ||x||_1  s.t.  Ax = b
%
A=Phi*C';  
% x0=A'*y;   %��С������Ϊl1��С���ĳ�ʼֵ����
% ��l1-MAGIC��MATLAB�������l1��С������
% xh1=l1eq_pd(x0,A,[],y,1e-3);
xh1=l1eq_pd(zeros(N,1),A,[],y,1e-3);  %���Բ�����ʼ�Ĺ���
%%  l1������С��  l1_ls������
% l1_ls����Ż�������
% minimize ||A*x-y||^2 + lambda*sum|x_i|,
%
lambda  = 0.01; % ���򻯲���
rel_tol = 1e-3; % Ŀ����Զ�ż��϶
quiet=1;   %������м���
[xh2,status]=l1_ls(A,y,lambda,rel_tol,quiet);
% At=A';
% [xh2,status]=l1_ls(A,At,M,N,y,lambda,rel_tol,quiet);
%% 5.�ָ��źź�ԭʼ�źűȽ�
figure
plot(t,C'*xh1,'k.-',t,x2,'r-')
xlim([0,t(end)])
legend('l1-MAGIC�ָ��ź�','ԭʼ�ź�')

figure
plot(t,C'*xh2,'k.-',t,x2,'r-')
xlim([0,t(end)])
legend('l1-ls�ָ��ź�','ԭʼ�ź�')

%% 6. ISTA������l1��С������
A=Phi*C';  
[theta,erro_rnn]=CS_ISTA( y,A,0.05);
figure
plot(erro_rnn,'-*')
legend('ISTA���')
%% 7.�ָ��źź�ԭʼ�źűȽ�
figure
plot(t,C'*theta,'k.-',t,x2,'r-')
xlim([0,t(end)])
legend('ISTA�ָ��ź�','ԭʼ�ź�')

%% 8. FISTA������l1��С������
A=Phi*C';  
[theta,erro_rnn]=CS_FISTA( y,A,0.05);
figure
plot(erro_rnn,'-*')
legend('FISTA���')
%% 9.�ָ��źź�ԭʼ�źűȽ�
figure
plot(t,C'*theta,'k.-',t,x2,'r-')
xlim([0,t(end)])
legend('FISTA�ָ��ź�','ԭʼ�ź�')
%% 10.��L0���⣬�ý��Ʒ�����Ҳ����Lp����  SL0�㷨
% A*x=y, using  Smoothed L0
% minimize ||x||_0
% subject to A*x=y
A=Phi*C';  
[theta]=CS_SL0( y,A,0.001,0.9,1,4);
figure
plot(t,C'*theta,'k.-',t,x2,'r-')
xlim([0,t(end)])
legend('SL0�ָ��ź�','ԭʼ�ź�')
