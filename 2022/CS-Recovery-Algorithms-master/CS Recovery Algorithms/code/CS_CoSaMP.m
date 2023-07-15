%% CS_CoSaMP  Algorithm 
%-----------------------------------------------------------------------------------------%
%  CS_CoSaMP  Algorithm (ѹ����������ƥ��׷�ٷ� Orthogonal Matching Pursuit)   
%  ���룺y---�����ź�  M X 1
%           A---�ָ�����  M X N
%           K---��������
% ��� ��theta---���Ƶ�ϡ������ N X 1
%            erro_res---ÿ�ε��������
%  ����ˣ� ����                                    Email: aresmiki@163.com
%  ���ʱ�䣺2017��04��26��  ���Ͻ�ͨ��ѧǣ�����������ص�ʵ����
%                                        SWJTU  TPL
%  �ο�����1��Needell D��Tropp J A 
%  CoSaMP��Iterative signal recovery from incomplete and inaccurate samples[J]��
% Applied and Computation Harmonic Analysis��2009��26��301-321.
% �ο�����2��D.Needell, J.A. Tropp��
% CoSaMP: Iterative signal recoveryfrom incomplete and inaccurate samples[J]. 
% Communications of theACM��2010��53(12)��93-100.
%------------------------------------------------------------------------------------------%

%%
function [ theta,erro_res ] = CS_CoSaMP( y,A,K )
    [m,n] = size(y);
    if m<n
        y = y'; 
    end
    [M,N] = size(A); %���о���AΪM*N����
    theta = zeros(N,1); %�����洢�ָ���theta(������)
    pos_num = []; %�������������д洢A��ѡ��������
    res = y; %��ʼ���в�(residual)Ϊy
    for kk=1:K %������K��
        %(1) Identification
        product = A'*res; %���о���A������в���ڻ�
        [val,pos]=sort(abs(product),'descend');
        Js = pos(1:2*K); %ѡ���ڻ�ֵ����2K��
        %(2) Support Merger
        Is = union(pos_num,Js); %Pos_theta��Js����
        %(3) Estimation
        %At������Ҫ������������Ϊ��С���˵Ļ���(�������޹�)
        if length(Is)<=M
            At = A(:,Is); %��A���⼸����ɾ���At
        else %At�����������������б�Ϊ������ص�,At'*At��������
            if kk == 1
                theta_ls = 0;
            end
            break; %����forѭ��
        end
        %y=At*theta��������theta����С���˽�(Least Square)
        theta_ls = (At'*At)^(-1)*At'*y; %��С���˽�
        %(4) Pruning
        [val,pos]=sort(abs(theta_ls),'descend');
        %(5) Sample Update
        pos_num = Is(pos(1:K));
        theta_ls = theta_ls(pos(1:K));
        %At(:,pos(1:K))*theta_ls��y��At(:,pos(1:K))�пռ��ϵ�����ͶӰ
        res = y - At(:,pos(1:K))*theta_ls; %���²в� 
        erro_res(kk)=norm(res,2);
        if norm(res)<1e-6 %Repeat the steps until r=0
            break; %����forѭ��
        end
    end
    theta(pos_num)=theta_ls; %�ָ�����theta
end