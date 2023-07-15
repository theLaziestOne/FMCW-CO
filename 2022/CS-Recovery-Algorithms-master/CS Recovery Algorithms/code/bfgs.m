
function [x,val,k]=bfgs(fun,gfun,x0)
%���ܣ���BFGS�㷨�����Լ�����⣺min f(x)
% ���룺x0�ǳ�ʼ�㣬fun,gfun�ֱ���Ŀ�꺯�������ݶȣ�
%varargin������ɱ�����������򵥵���bfgsʱ���Ժ�������
% ������������ѭ������ʱ���ᷢ����Ҫ����
%�����x,val�ֱ��ǽ������ŵ������ֵ��k�ǵ���������
% syms x1 x2;
maxk=500;       %��������������
rho=0.55; sigma=0.4; epsilon=1e-6;      %����һЩ�����������������
k=0; n=length(x0);
Bk=eye(n);      %Bk=feval('Hesse',x0);
x=x0;
%%
while(k<maxk)
    gk=feval(gfun,x0);      %���㾫�� ����ֵ̫С��С��epsilon�Ͳ�������
    if(norm(gk)<epsilon)
        break;
    end                         %������ֹ׼��
    dk=-Bk\gk;      %�ⷽ���飬������������
    m=0;mk=0;
    while(m<20)     %��Armijo�����󲽳�
        newf=feval(fun,x0+rho^m*dk);
        oldf=feval(fun,x0);
        if(newf<oldf+sigma*rho^m*gk'*dk)
            mk=m;
            break;
       end
    m=m+1;
    end
%BFGS����
x=x0+rho^mk*dk;
sk=x-x0;  yk=feval(gfun,x)-gk;
if(yk'*sk>0)
    Bk=Bk-(Bk*sk*sk'*Bk)/(sk'*Bk*sk)+(yk*yk')/(yk'*sk);
end
k=k+1;      x0=x;
% val=feval(fun,x0);
end
%%
val=feval(fun,x0);