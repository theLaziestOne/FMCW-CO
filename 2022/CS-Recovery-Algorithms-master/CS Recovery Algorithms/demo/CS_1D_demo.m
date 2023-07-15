%% ��������
% minimize ||x||_1
% subject to: (||Ax-y||_2)^2<=eps;
% minimize :  (||Ax-y||_2)^2+lambda*||x||_1
% y�����п��ܺ��� y=y+w
%
%%
clc;clear all;
%% 1.����һ������г���ź�
lam=0.37;
itrs=400;
m=380;
sig=0.5;
n=1024;
dt=1/2000;
T=1023*dt;
t=0:dt:T;
t=t(:);
x=sin(697*pi*t)+sin(1975*pi*t);
Dn=dctmtx(n);

%% 2.����������� 
rand('state',15);
q=randperm(n);
q=q(:);
y=x(q(1:m));
randn('state',7)
w=sig*randn(m,1);  %��������
yn=y+w;  %ѹ������������
Psi1=Dn';
%% 3. �ع��ź�  ISTA
A=Psi1(q(1:m),:);
% [xh,err]=CS_ISTA(yn,A,lam,itrs);  %ISTA
[xh,err]=CS_ISTA(yn,A,lam);  %ISTA
xx=Psi1*xh;
figure
plot(err,'*-')
legend('ISTA���')

figure
plot(t,x,'b',t,xx,'r');
legend('DCT-ϡ���ź�','ISTA�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','ISTA�ع��ź�')

%% 3. �ع��ź�  FISTA
A=Psi1(q(1:m),:);
% [xh,err]=CS_FISTA(yn,A,lam,itrs);  %FISTA
[xh,errr]=CS_FISTA(yn,A,lam);  %FISTA
xx=Psi1*xh;
figure
plot(errr,'*-')
legend('FISTA���')

figure
plot(t,x,'b',t,xx,'r');
legend('DCT-ϡ���ź�','FISTA�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','FISTA�ع��ź�')

%% 4. �ع��ź�  OMP
A=Psi1(q(1:m),:);
[xh,errr]=CS_OMP(yn,A,100);  %OMP
xx=Psi1*xh';
figure
plot(errr,'*-')
legend('OMP���')

figure
plot(t,x,'b',t,xx,'r');
legend('DCT-ϡ���ź�','OMP�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','OMP�ع��ź�')

%% 4. �ع��ź�  CoSaMP
A=Psi1(q(1:m),:);
[xh,errr]=CS_CoSaMP(yn,A,100);  %CoSaMP
xx=Psi1*xh;
figure
plot(errr,'*-')
legend('CoSaMP���')

figure
plot(t,x,'b',t,xx,'r');
legend('DCT-ϡ���ź�','CoSaMP�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','CoSaMP�ع��ź�')

%% 5. l1������С�� l1-Magic������  ����Բģ��Ϊmin_x ||x||_1  s.t.  Ax = b�������ʺϸ�ģ��
A=Psi1(q(1:m),:); 
% x0=A'*y;   %��С������Ϊl1��С���ĳ�ʼֵ����
% ��l1-MAGIC��MATLAB�������l1��С������
% xh1=l1eq_pd(x0,A,[],y,1e-3);
xh=l1eq_pd(zeros(n,1),A,[],y,1e-3);  %���Բ�����ʼ�Ĺ���
xx=Psi1*xh;
figure
plot(t,x,'b',t,xx,'r');
legend('DCT-ϡ���ź�','l1-Magic�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','l1-Magic�ع��ź�')

%% 5. l1������С�� l1-ls������   ���ģ��minimize ||A*x-y||^2 + lambda*sum|x_i|,�ǳ����ϸ�����
A=Psi1(q(1:m),:); 
lambda  = 0.01; % ���򻯲���
rel_tol = 1e-3; % Ŀ����Զ�ż��϶
quiet=1;   %������м���
[xh,status]=l1_ls(A,y,lambda,rel_tol,quiet);
xx=Psi1*xh;
figure
plot(t,x,'b',t,xx,'r');
legend('DCT-ϡ���ź�','l1-ls�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','l1-ls�ع��ź�')



%% 6. SL0   ���ģ��minimize ��A*x-y�� + lambda*sum|x_i|
A=Psi1(q(1:m),:); 

[xh,Spare_L0]=CS_SL0( y,A,0.001,0.9,2,3);

xx=Psi1*xh;
figure
plot(t,x,'b',t,xx,'r');
legend('DCT-ϡ���ź�','SL0�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','SL0�ع��ź�')

%% 6. SL0   ���ģ��minimize ||A*x-y||_2 + lambda*sum|x_i|
A=Psi1(q(1:m),:); 

[xh,Spare_L0]=CS_RSL0( y,A,0.001,0.9,2,3,0.01);

xx2=Psi1*xh;
figure
plot(t,x,'b',t,xx2,'r');
legend('DCT-ϡ���ź�','RSL0�ع��ź�')

figure
t1=50*dt:dt:100*dt;
plot(t1,x(50:100),'b',t1,xx2(50:100),'r','linewidth',1.5)
legend('DCT-ϡ���ź�','RSL0�ع��ź�')

figure
plot(t,x,'b',t,xx,'r',t,xx2,'k');
legend('DCT-ϡ���ź�','SL0�ع��ź�','RSL0�ع��ź�')

figure
bar([norm(x-xx),norm(x-xx2)],'r')



