 %{ 输入参数为 信号矩阵块:data  雷达参数结构体：radar
 %输出为量测得到的信息 包含 距离 角度 多普勒径向速度 以列排布 有多少列即得到多少个目标
 %注意在这里针对数模的数据进行计算的时候不能计算多普勒信息
 %}
function measurement=FMCWsignalProcessing(data,radar,s)
    %% FFTnum 指定的是傅里叶变换的点数 以及数据的相关信息
    %% 第一个是chirp数 第二个是虚拟天线数 第三个是采样数
        if s=="binary"
            FFTnum=radar.FFTnum;
        else
            FFTnum=radar.rawFFTnum;
        end

    %% 根据获取的信号的维度信息 分别对信号进行处理
        if(length(size(data))==2)%% 此时三个维度分别为 chirp Na sampling_Num
            FFTnum(1)=1;
        end
    %% 设计矩阵 来存距离FFT 并考虑对比将多个天线根据
        FFT_R=zeros(FFTnum);%存放的是对应的距离FFT的信息
        FFT_RA=zeros(FFTnum);%存放的是对应的距离角度信息
        FFT_RWin=zeros(FFTnum);%查看加窗的影响
        FFT_RAWin=zeros(FFTnum);%查看加窗的影响
        
    %% 相干计算各个天线的傅里叶变换结果
        FFT_R_Sum=zeros(FFTnum(1),FFTnum(3));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FFT操作%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 距离FFT
        for i=1:FFTnum(1)
            fft1d=fft(squeeze(data(i,:,:)),FFTnum(3),2);%% fft matlab自带 点数自己指定 指定进行FFT的维度
            FFT_R(i,:,:)=fft1d;
            for j=1:FFTnum(2)
                a=squeeze(fft1d(j,:));
                FFT_R_Sum(i,:)=FFT_R_Sum(i,:)+a;
            end
        end
    %% 距离--角度 2DFFT
        for i=1:FFTnum(1)
            fft2d=fft2(squeeze(data(i,:,:)),FFTnum(2),FFTnum(3));%% fft matlab自带 点数自己指定 指定进行FFT的维度
            fft2d=fftshift(fft2d,1);
            FFT_RA(i,:,:)=fft2d;
        end
        
        for i=1:FFTnum(1)
            %% 加窗 Range
            for j=1:FFTnum(2)
                Rwin=hanning(FFTnum(3));
                fft1d=fft(squeeze(data(i,j,:)).*Rwin,FFTnum(3));
                FFT_RWin(i,j,:)=fft1d;
            end  
            %% RA 加窗
            for k=1:FFTnum(3)
                AWin=hanning(FFTnum(2));
                temp=squeeze(data(i,:,k));
                temp=temp'.*AWin;
                fft2d=fft(temp,FFTnum(2),1);
                fft2d=fftshift(fft2d);
                FFT_RAWin(i,:,k)=fft2d;
            end
        end   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%超分辨测角%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% 确定角度搜索范围及对应的尺度
        theta_scan=linspace(-90,90,1024);
        array=0:1:85;
        %% DBF 测角 在这里由于有多个快拍 对DBF结果取平均
        DBF_power=zeros(FFTnum(1),length(theta_scan));
        for k=1:FFTnum(1)
            for l=1:1%radar.sample_num
                for j=1:length(theta_scan)
                    a_tehtaDBF=exp((-1i*2*pi*radar.RxDis*sind(theta_scan(j))/radar.lambda).*array);
                    temp=a_tehtaDBF*squeeze(data(k,:,l))';
                    temp=abs(temp);
                    DBF_power(k,j)=DBF_power(k,j)+temp;
                end
            end
            DBF_power(k,:)=DBF_power(k,:)/max(DBF_power(k,:));
        end
        DBF_power=20*log10(DBF_power);
        %% capon测角
        capon_power=zeros(FFTnum(1),length(theta_scan));
        for k=1:FFTnum(1)
            siganl=squeeze(data(k,:,:));
            R=(siganl*siganl');
            R=inv(R')/radar.sample_num;%注意这里求逆了
            for j=1:length(theta_scan)
                a_theta_capon=exp((-1i*2*pi*radar.RxDis*sind(theta_scan(j))/radar.lambda).*array);%注意这里放进去的是角度不是弧度
                %temp=abs(a_theta_capon*R*a_theta_capon');
                capon_power(k,j)=1/abs(a_theta_capon*R*a_theta_capon');
            end
            capon_power(k,:) = 20*log10(capon_power(k,:)./max(capon_power(k,:)));
        end
        %% music测角
        MUSIC_power=zeros(FFTnum(1),length(theta_scan));
        for k=1:FFTnum(1)
            signal=squeeze(data(k,:,:));
            R=signal*signal'/radar.sample_num;%对多个快拍取均值 其实在这里有统计估计的作用
            [EV,D] =  eig(R);     %特征值分解,D为由INVR的特征值构成的对角矩阵，EV为其特征向量构成的矩阵  【这里是对协方差矩阵的分解！】
            D=diag(D);%提取出来特征值
            [~,I] = sort(D);  %从小到大排序，I对应EVA中元素在原来EVA中的位置。
            Q=EV(:,I(1:end-2));%提出来噪声子空间
            %% 注意此时已经完成对于特征值的计算
            for j=1:length(theta_scan)
                a_theta_Music=exp((-1i*2*pi*radar.RxDis*sind(theta_scan(j))/radar.lambda).*array);%注意这里放进去的是角度不是弧度
                a_theta_Music=a_theta_Music';
                MUSIC_power(k,j)=abs((a_theta_Music'*a_theta_Music)/(a_theta_Music'*Q*Q'*a_theta_Music));
            end
             MUSIC_power(k,:) = 20*log10(MUSIC_power(k,:)./max(MUSIC_power(k,:)));  
        end

        %% DML测角（理论上最佳？）

%% CFAR检测
for i=1:FFTnum(2)

end


%% 多普勒频移补偿
%compensation=DoplarForVel();

%% 角度-music 谱峰搜索

    %% R-FFT
%     %% 绘制的是每一帧的每一个天线的距离FFT
%         for i=1:FFTnum(1)
%             figure(10001);
%             for j=1:FFTnum(2)
%                 box on;
%                 temp=abs(squeeze(FFT_R(i,j,:)));
%                 plot(radar.rawR,temp);
%                 hold on;
%         
%             end
%              title("R-without-Window");
%             %pause(0.2);
%         end
%     %% 加窗距离 谱图
%         for i=1:FFTnum(1)
%             figure(10002);
%             for j=1:FFTnum(2)
%                 box on;
%                 temp=abs(squeeze(FFT_R(i,j,:)));
%                 plot(radar.rawR,temp);
%                 hold on;
%     
%             end
%             title("R-with-Window");
%             %pause(0.2);
%         end
%     %% 绘制天线叠加起来的图
%         figure(10004);
%         for i=1:FFTnum(1)
%             temp=abs(FFT_R_Sum(i,:));
%             plot(radar.rawR,temp);
%             %hold on;
%             %pause(0.2);
%         end
    %% 绘制各种测角算法的对比
        figure(1005);
        for i=1:FFTnum(1)
            plot(theta_scan,DBF_power(i,:),'r');
            hold on;
            
            plot(theta_scan,capon_power(i,:),'g');
            hold on;
            
            plot(theta_scan,MUSIC_power(i,:),'b');
            hold on;

            pause(0.2);
            if i<FFTnum(1)
                clf;
            end
        end
        legend(["DBF","capon","MUSIC"]);
%% RA-FFT
    %% 绘制每一帧的R-A图
    figure(10086);
    for i=1:FFTnum(1)
        mesh(db(abs(squeeze(FFT_RA(i,:,:)))));
        pause(0.2);
        if i<FFTnum(1)
            clf;
        end
    end
    %% 绘制每一帧加窗的R-A图
    figure(10087);
    for i=1:FFTnum(1)
        mesh(db(abs(squeeze(FFT_RAWin(i,:,:)))));
        pause(0.2);
        if i<FFTnum(1)
            clf;
        end
    end
end