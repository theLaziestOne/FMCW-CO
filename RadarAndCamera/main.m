clc;
clear all;
close all;

for frame = 3 : 899
%% 雷达数据读取，以及一些基本参数
% 原始数据和图片存放位置，目前只试过2019_04_09_bms1000这个文件夹下的
filename = ['D:\GameDownload\dataset\Automotive\2019_04_09_bms1000\radar_raw_frame\' num2str(frame, '%06d') '.mat']; 
imagename = ['D:\GameDownload\dataset\Automotive\2019_04_09_bms1000\images_0\' num2str(frame-3, '%010d') '.jpg'];
rawData = load(filename);
rawData = rawData.adcData;
% 数据格式为采样点数、chirp数、接收天线数、发送天线数
[rangeBin, dopplerBin, rxNums, txNums] = size(rawData);
radar.samples = rangeBin; % 每个chirp采样点数
radar.chirps = dopplerBin; % chirp数
radar.rxNums = rxNums; % 接收天线数
radar.txNums = txNums; % 发送天线数
radar.startFreq = 77e9; % 调频初始频率
radar.bandWidth = 0.67e9; % 调频带宽
radar.tc = 60e-6; % 持续时间
radar.t_chirp = radar.txNums * radar.tc;% 单根天线前后相邻发送的两个chirp的周期
radar.slope = 21e12; % 斜率
radar.fs = 4e6; % 采样率
framePeriodicity_msec = 33.33333;  % 帧率
c = 3e8; % 光速
radar.lambda = c / radar.startFreq; % 波长
radar.d = radar.lambda / 2; % 接收阵元间距

%% 通过计算得到的各种参数
maxRange = radar.fs * c / 2 / radar.slope; % 最大可测距离
rangeRes = c / 2 / radar.bandWidth; % 距离分辨率
maxVel = radar.lambda / 4 / (radar.t_chirp);% 最大可测速度
velRes = radar.lambda / (2*radar.chirps*radar.tc);% 速度分辨率
% 最大不模糊角度
maxAngle = asin(radar.lambda/(2*radar.d));
maxAngle = maxAngle / pi * 180;
angleRes = 2 / (radar.txNums*radar.rxNums); % 角度分辨率

%% range-fft
rawData = reshape(rawData, [rangeBin, dopplerBin, rxNums*txNums]);
rangeData = zeros(1, rangeBin);
for i = 1 : rxNums*txNums
    for j = 1 : dopplerBin
        rangeData  = rangeData + fft(rawData(:, j, i), rangeBin, 1);
    end
end
rangeAxis = [0: rangeBin-1] / rangeBin * maxRange;
% plot(rangeAxis, db(abs(rangeData)));

%% range/doppler-fft
rangeFFT = zeros(rangeBin, dopplerBin, rxNums*txNums);
dopplerFFT = rangeFFT;
for i = 1 : rxNums * txNums
    rangeFFT(:, :, i) = fft(squeeze(rawData(:, :, i)), rangeBin, 1);
    dopplerFFT(:, :, i) = fftshift(fft(rangeFFT(:, :, i), dopplerBin, 2), 2);
    
end

%% 多通道的非相干积累
RDfftMatrix = dopplerFFT;
accData = zeros(rangeBin, dopplerBin);
for ii = 1 : txNums*txNums
    dopplerFFT(:, (dopplerBin-3)/2: (dopplerBin+3)/2, ii) = 0; % 零速通道直接置0,去除静止目标和直流分量
    accData = accData + abs(squeeze(dopplerFFT(:, :, ii)));
end
dopplerFFT = accData;
% mesh(dopplerFFT);

%% CFAR，这里可修改，目前是按照调皮连续波的代码写的，2次CFAR，先对doppler维做CFAR，再对range维做CFAR
cfarPara.guardCell = 2; % 保护单元
cfarPara.trainCell = 4; % 训练单元
cfarPara.SNR = 13;
leftBlock = zeros(rangeBin, cfarPara.guardCell+cfarPara.trainCell);
rightBlock = zeros(rangeBin, cfarPara.guardCell+cfarPara.trainCell);
newData = [leftBlock, db(abs(dopplerFFT)), rightBlock];
[L, R] = size(newData);
cfarList = [];
for i = 1 : rangeBin
   for j = cfarPara.guardCell+cfarPara.trainCell+1 : R - (cfarPara.guardCell+cfarPara.trainCell)
       leftNoise = mean(newData(i, j - (cfarPara.guardCell+cfarPara.trainCell) : j-cfarPara.guardCell));
       rightNoise = mean(newData(i, j+cfarPara.guardCell : j+cfarPara.guardCell+cfarPara.trainCell));
       noise = (leftNoise + rightNoise) / 2;
       if j < 13
          noise = rightNoise; 
       end
       if j > 242
           noise = leftNoise;
       end
       deltaSNR = newData(i, j) - noise;
       if deltaSNR > cfarPara.SNR
           cfarList = [cfarList j-(cfarPara.guardCell+cfarPara.trainCell)];
       end
       
   end
end
upBlock = zeros(cfarPara.guardCell+cfarPara.trainCell, dopplerBin);
downBlock = zeros(cfarPara.guardCell+cfarPara.trainCell, dopplerBin);
newData = [upBlock; db(abs(dopplerFFT)); downBlock];
cfarSet = [];
cfarList = unique(cfarList);
[L, R] = size(newData);
cfarDbMatrix = zeros(radar.samples, radar.chirps);
for i = 1 : size(cfarList, 2)
    for j = cfarPara.guardCell+cfarPara.trainCell+1 : L - (cfarPara.guardCell+cfarPara.trainCell)
        upNoise = mean(newData(j-(cfarPara.guardCell+cfarPara.trainCell): j-cfarPara.guardCell, cfarList(i)));
        downNoise = mean(newData(j+cfarPara.guardCell:j+(cfarPara.guardCell+cfarPara.trainCell) , cfarList(i)));
        noise = (upNoise + downNoise) / 2;
        if j < 13
            noise = downNoise;
        end
        if j > 115
            noise = upNoise;
        end
        deltaSNR = newData(j, cfarList(i)) - noise;
        if deltaSNR > cfarPara.SNR
           cfarSet = [cfarSet, [j - (cfarPara.guardCell+cfarPara.trainCell); cfarList(i)]];
           cfarDbMatrix(j - (cfarPara.guardCell+cfarPara.trainCell), cfarList(i)) = db(abs(dopplerFFT(j - (cfarPara.guardCell+cfarPara.trainCell), cfarList(i))));
       end
    end
end

%% 峰值搜索
peakSearchVal = zeros(rangeBin, dopplerBin);
peakSearchIdx = [];
for i = 1 : size(cfarSet, 2)
    rangeIdx = cfarSet(1, i);
    dopplerIdx = cfarSet(2, i);
    if rangeIdx ~= 1 && dopplerIdx ~= 1 && rangeIdx ~= rangeBin && dopplerIdx ~= dopplerBin
        if cfarDbMatrix(rangeIdx-1, dopplerIdx) < cfarDbMatrix(rangeIdx, dopplerIdx) && ...
                cfarDbMatrix(rangeIdx+1, dopplerIdx) < cfarDbMatrix(rangeIdx, dopplerIdx) && ...
                cfarDbMatrix(rangeIdx, dopplerIdx-1) < cfarDbMatrix(rangeIdx, dopplerIdx) && ...
                cfarDbMatrix(rangeIdx, dopplerIdx+1) < cfarDbMatrix(rangeIdx, dopplerIdx)
            peakSearchVal(rangeIdx, dopplerIdx) = cfarDbMatrix(rangeIdx, dopplerIdx);
            peakSearchIdx = [peakSearchIdx, [rangeIdx; dopplerIdx]];
        end
    end
end
% mesh(peakSearchVal);

%% 速度解模糊。这里可以加速度解模糊的代码，当前最大可测速度8.1169m/s，正常自行车速不会大于该值，所以没加

%% 多普勒补偿，一般只有TDM体制的MIMO需要
for i = 1 : size(peakSearchIdx, 2)
   rangeIdx = peakSearchIdx(1, i);
   dopplerIdx = peakSearchIdx(2, i);
   vest = (dopplerIdx-1)/dopplerBin * 2 * maxVel - maxVel;
   phi = 2*pi*(dopplerIdx - dopplerBin/2 - 1) / dopplerBin;
   for n = 1 : txNums
      for m = 1 : rxNums
         rawData(rangeIdx, dopplerIdx, (n-1)*rxNums+m) = rawData(rangeIdx, dopplerIdx, (n-1)*rxNums+m) * exp(-1j*(n-1)*phi);
      end
   end
end

%% 3D-fft
targetNums = size(peakSearchIdx, 2);
anglelist = [-maxAngle:1:maxAngle];
for i = 1 : targetNums
    rangeIdx = peakSearchIdx(1, i);
    dopplerIdx = peakSearchIdx(2, i);
    angleWin = hanning(rxNums*txNums);
    anglefft = fftshift(fft(squeeze(RDfftMatrix(rangeIdx, dopplerIdx, :)).*angleWin, size(anglelist, 2)));
%     figure;
%     plot((abs(anglefft)));
    
end

%% MUSIC,高SNR、信源数已知、快拍数足够情况下可以得到较好效果
% 但是其实这里效果还是不太好，角度的估计偶尔会出现大偏差，按照ytx的想法，应该可
% 以先3D-fft确定角度区间之后再进行MUSIC的谱峰搜索
angleIdx = [];
for t = 1 : targetNums
    Sr = rawData(:, peakSearchIdx(2, t), :);
    Sr = squeeze(Sr);
    R = Sr.';
    R = R * R';
    R = R / rangeBin;
    [u, l] = eig(R);
    G = u(:, 1:end-4);
    phi = 2*pi*radar.d*sin([-maxAngle:1:maxAngle]/180*pi)/radar.lambda;
    atheta = exp(1i * [0:rxNums*txNums-1]' * phi);
    ptheta = zeros(1, size(phi, 2));
    for n = 1 : size(phi, 2)
%         ptheta(n) = 1 / (atheta(:, n)'*inv(R)*atheta(:, n));% 这一行表示用的capon是测角
        ptheta(n) = 1 / (atheta(:, n)'*G*G'*atheta(:, n));% 这一行表示用的是music测角
    end
    [~, p] = max(abs(ptheta));
    
    angleIdx = [angleIdx p];
%     figure;
%     plot(abs(ptheta));
end
angleAxis = [-maxAngle:1:maxAngle];
angleList = angleAxis(angleIdx);

%% 画图，横坐标角度，纵坐标距离
angleData = [];
rangeData = [];
for t = 1 : targetNums
    angleData = [angleData angleList(t)];
    rangeData = [rangeData rangeAxis(peakSearchIdx(1, t))];
end
subplot(1, 2, 1);
% 画出所有点
scatter(angleData, rangeData, '*');
xlim([-maxAngle maxAngle]);
ylim([0 maxRange]);
% 读取图像
subplot(1, 2, 2);
image = imread(imagename);
imshow(image);

pause(0.05);

%% DML,确定性最大似然法，对SNR要求较高，可以实现超分辨，单快拍结果似乎也能接受
% R = Sr.';
% R = R * R'/rangeBin/dopplerBin;
% p_atheta = zeros(rxNums*txNums, rxNums*txNums, size(phi,2));
% target_serched = zeros(1,targetNums);
% maxTrace = 0;
% temp = zeros(1, size(phi, 2));
% for i = 1 : size(phi, 2)
%     p_atheta(:, :, i) = atheta(:,i) * inv(atheta(:,i)'*atheta(:,i)) * atheta(:,i)';
%     temp(i) = trace(squeeze(p_atheta(:, :, i)) * R);
%     if temp(i) > maxTrace
%        thetaIdx = i;
%        maxTrace = temp(i);
%     end
% end
% plot(abs(temp));

end




