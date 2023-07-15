%% CS_IRLS  Iteratively reweighted algorithms for compressive sensing
% ���룺y---�����ź� M X 1
%          A---�ָ����� M X N
%          p---α���� 1--0֮��
%          deltaT---��С��delta ����delta����̫С,deltaԽСԽ�ӽ���l0����
%          r---delta����������
%          mu---��С�ĸ��²��������� 2-4ȡֵ ������
%          L---ѭ������ Ĭ��ȡֵ3
% �����ys---�ָ����ź� N X 1
%    
% 
%  minimize ||x||_p
%  subject to Ax=y
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��30��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף� Chartrand and W. Yin,
% ��Iteratively Reweighted Algorithms for Compressed Sensing,�� 2008.
%---------------------------------------------------------------------------------------------------------------------%
function ys=CS_IRLS(y,A,p,epsT,r)
N=max(size(A));
M=min(size(A));
y=y(:);

eps=1;
ys=inv(A'*A)*A'*y;  %����һ����С���˽�
% ys=pinv(A)*y;

while (eps>epsT)
    
    w=(ys.^2+eps).^(p/2-1);  %����Ȩ��
%     w=(abs(ys)+eps).^(p-1);  %����Ȩ��
    Q=diag(1./w);
    yx=Q*A'*inv(A*Q*A')*y;  %����
    if(norm(yx-ys,2) < sqrt(eps)*r.^2)
        eps=eps*r;  %����eps  r������
    end
    ys=yx;
    
end

end
