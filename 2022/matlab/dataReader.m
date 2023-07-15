function data=dataReader(external_data)
    DATA= ['..\2022A\data_q' num2str(external_data) '.mat'];
    DATA=load(DATA);
    if external_data==1
        data=DATA.Z;
    end
    if external_data==2
        data=DATA.Z_noisy;
    end
    if external_data==3
        data=DATA.Z_time;
    end
    if external_data==4
        data=DATA.Z_antnoisy;
    end
end