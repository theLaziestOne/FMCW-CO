%% CS_OMP  Algorithm
%-------------------------------------------------------------------------------------%
%  CS_OMP  Algorithm (����ƥ��׷�ٷ� Orthogonal Matching Pursuit)   
%  ���룺y---�����ź�  M X 1
%           A---�ָ�����  M X N
%           K---��������
% ��� ��theta---���Ƶ�ϡ������ N X 1
%            erro_rn---ÿ�ε��������
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο����ף�Joel A. Tropp and Anna C. Gilbert 
%  Signal Recovery From Random Measurements Via Orthogonal Matching
%  Pursuit��IEEE TRANSACTIONS ON INFORMATION THEORY, VOL. 53, NO. 12,
%------------------------------------------------------------------------------------------%
%%   
function [ theta,erro_rn ] = CS_OMP( y,A,K )
N=max(size(A));
M=min(size(A));
theta=zeros(1,N);   %  ���ع�������    
Base_t=[];              %  ��¼�������ľ���
r_n=y;                  %  �в�ֵ
for times=1:K;                                    %  ��������(�������������,�õ�������ΪK)
    for col=1:N;                                  %  �ָ����������������
        product(col)=abs(A(:,col)'*r_n);          %  �ָ�������������Ͳв��ͶӰϵ��(�ڻ�ֵ) 
    end
    [val,pos]=max(product);                       %  ���ͶӰϵ����Ӧ��λ�ã�valֵ��posλ��
    Base_t=[Base_t,A(:,pos)];                       %  �������䣬��¼���ͶӰ�Ļ�����
    A(:,pos)=zeros(M,1);                          %  ѡ�е������㣨ʵ����Ӧ��ȥ����Ϊ�˼��Ұ������㣩
    aug_y=(Base_t'*Base_t)^(-1)*Base_t'*y;   %  ��С����,ʹ�в���С
    r_n=y-Base_t*aug_y;                            %  �в�
    erro_rn(times)=norm(r_n,2);      %�������
    pos_array(times)=pos;                         %  ��¼���ͶӰϵ����λ��
    if erro_rn(times)<1e-6 %
            break; %����forѭ��
    end
end
theta(pos_array)=aug_y;                           %  �ع�������
end