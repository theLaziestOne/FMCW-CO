function figure_plot(A_intervals,Angle,D_intervals,Distance,S_intervals,Speed,method)
%% 角度
if length(Angle{1}) > 1
    figure
    hold on
    grid on
    for i = 1:length(Angle)
        plot(A_intervals, log(abs(Angle{i})))
    end
    title("Angel spectrum (" + method + ")")
    xlabel("Angel (°)")
    ylabel("Power (db)")
end

%% 距离
if length(Distance{1}) > 1
    figure
    hold on
    grid on
    for i = 1:length(Distance)
        plot(D_intervals, log(abs(Distance{i})))
    end
    title("Distance spectrum (" + method + ")")
    xlabel("Distance (m)")
    ylabel("Power (db)")
end

%% 速度
if length(Speed{1}) > 1
    figure
    hold on
    grid on
    for i = 1:length(Speed)
        plot(S_intervals, log(abs(Speed{i})))
    end
    title("Speed spectrum (" + method + ")")
    xlabel("Speed (m/s)")
    ylabel("Power (db)")
end
end

