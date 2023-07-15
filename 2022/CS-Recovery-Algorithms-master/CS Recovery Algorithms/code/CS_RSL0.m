%% CS_RSL0  Robust Smoothed l0-Pseudonorm Algorithm
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
%  subject to ||Ax-y||_2<e_eps
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��30��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף�H. Mohimani, M. Babie-Zadeh, and C. Jutten,
% ��A fast approach for overcomplete sparse decomposition based on smoothed l0-norm,��
% IEEE Trans. Signal Process., vol. 57, no. 1, pp. 289-301, Jan. 2009.
%---------------------------------------------------------------------------------------------------------------------%
%%
function [xs,valL0]=CS_RSL0(y,A,deltaT,r,mu,L,e_eps);
% rΪdelta��С������<1��
y=y(:);
N=max(size(A));
M=min(size(A));
%% ��ʼ��һЩ����
pinv_A=pinv(A);
% pinv_A=A'*inv(A*A');
xs=pinv_A*y;  %�õ�һ����С���˽���Ϊ��ʼֵ
delta=2*max(abs(xs));  %�������2-4�������delta>4*max(abs(ys)),exp(-s.^2/(2*delta.^2))=1
k=0; %��¼ѭ������
valL0(1)=0;
%  maximizing F_delta(x)=sum(f_delta(x(i)))=sum(exp(-x(i).^2)/(2*delta.^2))
%  subject Ax=y;
%  ��Lagrangian �Ƶ���L(x,lambda)= F_delta(x)-lambda'*(Ax-y)
%  ��x��lambda�ֱ������õ�KKT����
%  xƫ������[x(1)exp(-x(1).^2)/(2*delta.^2)),...,x(i)exp(-x(i).^2)/(2*delta.^2))-A'*lambda                (1)
%  lambdaƫ������Ax-y=0
% Ax=y����С���˽�Ϊ��x=pinv(A)*y,�൱�ڶ��Ż�����
% maximizing 0.5*x*x'
% subject Ax=y
% ��Lagrangian �Ƶ� L(x,lambda)= 0.5*x*x'-lambda'*(Ax-y)
%  xƫ������[exp(-x(1).^2)/(2*delta.^2)),...,exp(-x(i).^2)/(2*delta.^2))-A'*lambda                (2)
%  lambdaƫ������Ax-y=0
%  (1)��(2)�Աȣ�����delta���������exp((-x.^2)/(2*delta.^2))=1�������Ż�����Ľ⼸��һ��
%  delta>>max(xs),xs�Ƿ��̵���С���˽�
while delta>deltaT
    k=k+1;
for i=1:L   %L�����������㷨
    t_delta=xs.*exp(-abs(xs).^2/(2*delta^2));  %�����ݶ�ֵ
    xs=xs-mu*t_delta;  %�̶��������ݶ���������ȡ������ĺ���ֵ
    newy=A*xs-y;
    norm(newy,2)
    if norm(newy,2)>e_eps;   %ͶӰ
        xs=xs-pinv_A*newy; %ͶӰ�����м���
        break;
    end

end
   valL0(k+1)=N-sum(exp(-abs(xs).^2/(2*deltaT^2)));  %Ҫ�ô˹�ʽ�õ��õ�ֵdeltaT����̫С
   delta = delta * r;  %��������,����Сdelta��ԽСԽ�ã�ֻҪ��С��deltaT
  if (abs(valL0(k+1)-valL0(k))<1e-4);
     valL0=valL0(2:end);
     break;
 end
end
valL0=valL0(2:end);




