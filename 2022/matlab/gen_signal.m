function signal = gen_signal(para,radar,target,channel)
% 生成仿真数据
signal = complex(zeros(1,radar.waveform.SampleRate*radar.waveform.SweepTime,para.Nsweep));
for m = 1:para.Nsweep
    % Update radar and target positions
    [radar_pos,radar_vel] = radar.radarmotion(radar.waveform.SweepTime); % 更新雷达车辆的状态
    [tgt_pos,tgt_vel] = target.carmotion(radar.waveform.SweepTime); % 更新目标车辆的状态

    % Transmit FMCW waveform
    sig = radar.waveform(); % 产生波形
    txsig = radar.transmitter(sig); % TX天线发射波形

    % Propagate the signal and reflect off the target
    txsig = channel(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel); % 传输到目标的波形
    txsig = target.cartarget(txsig); % 目标反射波形

    % Dechirp the received radar return
    txsig = radar.receiver(txsig); % 接收器放大后波形
    dechirpsig = dechirp(txsig,sig); % 差频信号

    signal(1,:,m) = dechirpsig;
end
end
