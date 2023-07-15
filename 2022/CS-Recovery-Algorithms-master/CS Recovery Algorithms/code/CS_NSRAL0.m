%% CS_NSRAL0  Null-Space Reweigthted Approximate l0-Pseudonorm Algorithm
% ���룺y---�����ź� M X 1
%          A---�ָ����� M X N
%          deltaT---��С��delta ����delta����̫С,deltaԽСԽ�ӽ���l0����
%          r---delta����������
%          t---��С��һ����������ȷ����ʼ��delta�����ֵ����΢��һ��
%          eps---Ȩ�ظ��µ�һ����С����eps��ȷ����ĸ��Ϊ0
% �����yk---�ָ����ź� N X 1
%          valL0---ÿ�ε�����ϡ���׷�����
% 
%  minimize ||x||_0
%  subject to Ax=y
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��30��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף�J. K. Pant, W.-S. Lu, and A. Antoniou, 
% ��Reconstruction of sparse signals by minimizing a re-weighted approximate l0-norm in the
% null space of the measurement matrix,�� IEEE Inter. Midwest Symp. on Circuits-Syst, pp. 430�C433, 2010.
%---------------------------------------------------------------------------------------------------------------------%
%%
function [yk,valL0]=CS_NSRAL0(y,A,deltaT,r,t,eps);
% rΪdelta��С������<1��
y=y(:);
N=max(size(A));
M=min(size(A));
% Aά��ΪM X N������ռ� Vά��Ϊ N X (N-M)   ��ռ��һ������epsigΪ (N-M) X 1
%% ��ʼ��Null Space ��ռ���һ��������Ϊͨ����׼��
epsig=zeros((N-M),1);   %��ռ�����  
ys=A'*inv(A*A')*y; %һ����С���˽����ؽ�
w=ones(N,1);     %Ȩ�ؾ���,��ʼÿ��Ȩ�ض�Ϊ1
delta=max(y)+t;  %a reasonable initial value of theta ȷ����ʼ������͹��
k=0;
% V=null(A);   %matlab ����ֱ���������
[Q,R]=qr(A');   %��QR�ֽ�
V=Q(:,M+1:N);  % Q�����N-M�Ǿ���A����ռ����
valL0(1)=0;
 %% �����Ż�����
while (delta>deltaT)
    k=k+1;  %��¼��������
%  epsig=fminunc(@(epsigx) w'*(1-exp(-(ys+V*epsigx).^2./(2*delta.*delta)')),epsig);   %�����Ż�����
 [epsig,val,iters]=bfgs(@(epsigx) w'*(1-exp(-(ys+V*epsigx).^2./(2*delta.*delta)')),...
                   @(epsigx) (V'*(w.*((ys+V*epsigx).*exp(-(ys+V*epsigx).^2./(2*delta.*delta)')))),epsig);
 yk=ys+V*epsig;
 w=1./(abs(yk)+eps);  %Ȩ�ظ���
 delta=r*delta;
 [valL0(k+1)]= ones(1,N)*(1-exp(-(yk).^2./(2*deltaT.*deltaT)'));
 if (abs(valL0(k+1)-valL0(k))<1e-4);
     valL0=valL0(2:end);
     break;
 end
end
valL0=valL0(2:end);
end




