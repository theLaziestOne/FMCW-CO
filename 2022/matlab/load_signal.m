function [sig, radar] = load_signal(para)
if para.external_data < 5
    % 载入2022华为杯A题数据
    radar.fc = 7.88e10;%%基频
    radar.fs = 1 / (1.25e-7);%采样时间
    radar.tm = 3.2e-5;%一个chirp周期对应的时长
    radar.sample_num=radar.tm/radar.fs;%对应的采样点数
    radar.sweep_slope = 7.8986e13;%调频斜率
    radar.d = 0.0815 / 42;%天线孔径 得到的是天线间距 86个天线
    radar.lambda = para.c / radar.fc;%波长
    data = load(para.filename);
    switch para.external_data
        case 1
            sig = data.Z;
            return
        case 2
            sig = data.Z_noisy;
            return
        case 3
            data = data.Z_time;
            sig = zeros(size(data,2),size(data,3),size(data,1));
            for i = 1:size(data,1)
                sig(:,:,i) = data(i,:,:);
            end
            return
        case 4
            sig = data.Z_antnoisy;
            return
    end
elseif para.external_data==5
%     radar.fc = 7.88e10;
    radar.fs = 20*1e6;
    radar.tm = 2e-6;
    radar.sweep_slope = 2*pi*10*1e6/radar.tm;
    radar.d = 0;
%     radar.lambda = para.c / radar.fc;
%     data = load(para.filename);
%     sig = cell(86,1);
end

end
