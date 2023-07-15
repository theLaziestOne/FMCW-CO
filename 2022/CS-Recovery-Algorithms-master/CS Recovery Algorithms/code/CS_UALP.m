%% CS_UALP  Minimization of Approximate Lp Pseudonorm Using a Quasi-Newton Algorithm
% ���룺y---�����ź� M X 1
%          A---�ָ����� M X N
%          deltaT---��С��delta ����delta����̫С,deltaԽСԽ�ӽ���l0����
%          r---delta����������
%          mu---��С�ĸ��²��������� 2-4ȡֵ ������
%          L---ѭ������ Ĭ��ȡֵ3
% �����xs---�ָ����ź� N X 1
%          valL0---ÿ�ε�����ϡ���׷�����
% 
%  minimize ||x||_0
%  subject to Ax=y
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��30��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף�Pant J K, Lu W S, Antoniou A. 
% Unconstrained regularized Lp -norm based algorithm for the reconstruction of sparse signals[C]
% IEEE International Symposium on Circuits and Systems. IEEE, 2011:1740-1743.
%---------------------------------------------------------------------------------------------------------------------%
%% UALP��Pant J K�ڲ�ʿ�����еĶ��壬URLP��IEEE�����еĶ��壬�㷨һ��
function yk=CS_UALP(y,A,p)
y=y(:);
N=max(size(A));
M=min(size(A));
% Aά��ΪM X N������ռ� Vά��Ϊ N X (N-M)   ��ռ��һ������epsigΪ (N-M) X 1
%% ��ʼ��Null Space ��ռ���һ��������Ϊͨ����׼��
epsig=zeros((N-M),1);   %��ռ�����  
ys=A'*inv(A*A')*y; %һ����С���˽����ؽ�
% k=0;
% V=null(A);   %matlab ����ֱ���������
[Q,R]=qr(A');   %��QR�ֽ�
V=Q(:,M+1:N);  % Q�����N-M�Ǿ���A����ռ����
eps1=sqrt(1-p)*max(abs(ys));
epsT=1e-5;
T=9;
belta=log(eps1/epsT)/(T-1);
for i=2:(T-1)
    eps(i)=exp(-belta*i);
end
eps=[eps1,eps,epsT];
w=ones(N,1);     %Ȩ�ؾ���,ÿ��Ȩ�ض�Ϊ1,Ϊ�����
for k=1:T
      epsig=fminunc(@(epsigx) w'*((ys+V*epsigx).^2+eps(k).^2).^(p/2),epsig);   %�����Ż�����
%     [epsig,val,iters]=bfgs(@(epsigx) w'*((ys+V*epsigx).^2+eps(k).^2).^(p/2),...
%                    @(epsigx) p*V'*((((ys+V*epsigx).^2+eps(k).^2).^(p/2-1)).*(ys+V*epsigx)),epsig);             
end
yk=ys+V*epsig;



%%  BFGS�е���������
%     function [alpha1]=LSBFP(epsigk,xs,V,p,dk,deltaT,epsk)
%         lalpha1=0;deltaA=deltaT+1;
%         while(deltaA>deltaT)
%             gy=(xs+V*epsigk+alpha1*V*dk).^2+epsk*epsk;
%             Geps=-sum(((xs+V*epsigk).*(V*dk).*gy.^(p/2-1)))/sum(V*dk.*gy.^(p/2-1));
%             deltaA=Geps-alpha1;
%             alpha1=Geps;
%         end
%         
%     end

end

