%----------------------------------------------------------------------------------%
%  1-D�ź�ѹ�����е�ʵ��(����ƥ��׷�ٷ�Orthogonal Matching Pursuit)   
%  ������M>=K*log(N/K),K��ϡ���,N�źų���,���Խ�����ȫ�ع�
%  ����ˣ� ����  Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%---------------------------------------------------------------------------------%
clc
clear all
close all
%% 1. ����ԭʼ�ź�
fs=400;     %����Ƶ��
f1=25;         %��һ���ź�Ƶ��
f2=50;      %�ڶ����ź�Ƶ��
f3=100;     %�������ź�Ƶ��
f4=200;    %���ĸ��ź�Ƶ��
N=1024;    %�źų���
t=0:1/fs:(N-1)/fs;   
% x=0.3*cos(2*pi*f1*t)+0.6*cos(2*pi*f2*t)+0.1*cos(2*pi*f3*t)+0.9*cos(2*pi*f4*t);  %�����ź�
x=cos(2*pi*f1*t)+cos(2*pi*f2*t)+cos(2*pi*f3*t)+cos(2*pi*f4*t);  %�����ź�

%% 1.1�鿴ʱ��͸���Ҷ��
fx=abs(fftshift(fft(x)))*2/N;
fsf=(fs/N)*((1:N)-N/2-1);
figure
plot(fsf,fx)
%% �������������ֱ�ӽ���С��ֵ����Ϊ0
% fft_x=fft(x);
% fft_x(find(abs(fft_x)*2/N<0.1))=0;
% figure
% plot(fsf,fx,fsf,fftshift(fft_x*2/N),'--')
% xx=real(ifft(fft_x));
% figure
% plot(t,x,t,xx,'--')
% x=xx;
%% 2. ʱ���ź�ѹ�����У���ȡ����ֵ
K=8;   %�ź�ϡ��ȣ�����Ҷ���п�����
M=ceil(K*log(N/K));  %������,��������ѹ���̶ȣ����鹫ʽ
randn('state',2)
Phi=randn(M,N);  %  ��������(��˹�ֲ�������)
Phi=orth(Phi')';    %������
y=Phi*x';     %  ������Բ��� 

%% 3. L_1�������Ż��ع��źţ��в���ֵy�ع�x��
Psi=fft(eye(N,N))/sqrt(N);    %  ����Ҷ���任����,��Ϊ�ź�x�ڸ���Ҷ�ֵ���ϡ�裺theta=Psi*x.  ��x=Psi'*theta.
% ��С������ minimize:       ||theta||_0;
%                  subject to:     y=Phi*Psi'*theta;     ==   �� A=Phi*Psi'.   
A=Phi*Psi';                         %  �ָ�����(��������*�������任����);   x=Psi'*theta.

%%  4. ����ƥ��׷���ع��ź�
[ fft_y,erro_rn ] = CS_OMP( y,A,2*K );
figure
plot(erro_rn,'-*')
legend('OMP����ƥ��׷�����')
r_x=real(Psi'*fft_y');                         %  ���渵��Ҷ�任�ع��õ�ʱ���ź�

%% 5. �ָ��źź�ԭʼ�źŶԱ�

figure;
hold on;
plot(t,r_x,'k.-')                                 %  �ؽ��ź�
plot(t,x,'r')                                       %  ԭʼ�ź�
xlim([0,t(end)])
legend('OMP�ָ��ź�','ԭʼ�ź�')


%% 6. CoSaMP ����ѹ������ƥ��ķ�����l1��С������
A=Phi*Psi';                         %  �ָ�����(��������*�������任����);   x=Psi'*theta.
[theta,erro_rnn]=CS_CoSaMP( y,A,K );
figure
plot(erro_rnn,'-*')
legend('CoSaMPѹ������׷�����')
%% �ع����Ա�
cor_x=real(Psi'*theta);                         %  ���渵��Ҷ�任�ع��õ�ʱ���ź�
figure;
hold on;
plot(t,cor_x,'k.-')                                 %  �ؽ��ź�
plot(t,x,'r')                                       %  ԭʼ�ź�
xlim([0,t(end)])
legend('CoSaMP�ָ��ź�','ԭʼ�ź�')


%% ISTA��FISTA�����㷨���ģ��Ϊ��
% minimize   ||x||_1
% subject to:||Ax-y||_2<=eps
% second-order cone program(SOCP)��eps������ǿ��  
% ��������y����������Ҫ����x���ǽ������͹�Ż�����
% ����������������l1����
% minimize ||x||_1
% subject to: Ax=y;
%% 7. ISTA������l1��С������---�����Ż�������
A=Phi*Psi';                         %  �ָ�����(��������*�������任����);   x=Psi'*theta.
[theta,erro_rnn]=CS_ISTA( y,A,0.1,2000);
figure
plot(erro_rnn,'-*')
legend('ISTA���')
%% 8.�ָ��źź�ԭʼ�źűȽ�
figure
plot(t,real(Psi'*theta),'k.-',t,x,'r-')
xlim([0,t(end)])
legend('ISTA�ָ��ź�','ԭʼ�ź�')

%% 9. FISTA������l1��С������   �����Ż�������
A=Phi*Psi';                         %  �ָ�����(��������*�������任����);   x=Psi'*theta.
[theta,erro_rnn]=CS_FISTA( y,A,0.1,2000);
figure
plot(erro_rnn,'-*')
legend('FISTA���')
%% 10.�ָ��źź�ԭʼ�źűȽ�
figure
plot(t,real(Psi'*theta),'k.-',t,x,'r-')
xlim([0,t(end)])
legend('FISTA�ָ��ź�','ԭʼ�ź�')