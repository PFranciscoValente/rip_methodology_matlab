%------------------------------------------------------------------------
% File for initial processing of the dataset
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [features,label,all_labels,feat_header,days_events] = data_preprocessing(events,time,days_of_followUp)
    
    % SELECT THE DESIRED PERIOD OF TIME OF EVENTS OCCURENCE
        
    time_type = 0;

    if isequal(time,'14days')
       time_type = 1;
    elseif isequal(time,'30days')
        time_type = 2;
    elseif isequal(time,'6months')
        time_type = 3;
    elseif isequal(time,'1year')
        time_type = 4;
    end
        
    % LOAD DATASET

    current_directory = pwd;
    files_directory = '\datasets\';
    file_name = 'ACS_DATASET';
    file = strcat(current_directory,files_directory,file_name);
    [all_data,header,raw] = xlsread(file) ;

    % SELECT ONLY THE PATIENTS WITH THE DESIRED TIME OF FOLLOW-UP

    if isequal(days_of_followUp,'14days')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 14 D'));
    elseif isequal(days_of_followUp,'30days')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 30 D'));
    elseif isequal(days_of_followUp,'6months')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 180 D'));
    elseif isequal(days_of_followUp,'1year')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 365 D'));
    end

    patients_to_use = find(all_data(:,idx_fup)==1);
    % remove patients 93 and 760 (they have a lot of missing values)
    patients_to_use([93,760])=[];

    data = all_data(patients_to_use,:);

    % SELECT THE TYPE OF EVENTS (DEATH ONLY OR DEATH + MYOCARDIAL INF.)

    if isequal(events,'death')
        event_type = 'MORTE';
        event_days = 'DIAS MORTE';
    elseif isequal(events,'death + myocardial infarction')
        event_type = 'MORTE/EAM';
        event_days = 'DIAS MORTE/EAM';
    end

    % label: event ocurrance (1) or not (0) 
    [~,idx_label_occurence]= find(strcmp(header, event_type));
    [~,idx_label_days]= find(strcmp(header, event_days));

    ocurrence_events = data(:,idx_label_occurence); % events ocorruance in the total time of follow-up
    days_events = data(:,idx_label_days); 

    % label for the 4 types (14days,30days,6months,1year);
    all_labels = stratify_events(ocurrence_events,days_events);
    label = all_labels(:,time_type);

    % SELECT ALL THE FEATURES

    [~,varFinal] = find(strcmp(header, 'REPERFUSÃO REALIZADA'));
    all_info = data(:, [2:varFinal]); % do not consider the ID GERAL

    % REMOVE THE FEATURES WITH MORE THAN 10% OF MISSING DATA

    [~,var1] =  find(strcmp(header,'PESO'));
    [~,var2] = find(strcmp(header,'ALTURA'));
    [~,var3] = find(strcmp(header,'IMC'));
    [~,var4] = find(strcmp(header,'DEPRESSAO ST'));
    [~,var5] = find(strcmp(header,'HB GLICADA'));
    [~,var6] = find(strcmp(header,'PLAQUETAS'));
    [~,var7] = find(strcmp(header,'COLESTEROL TOTAL'));
    [~,var8] = find(strcmp(header,'HDL'));
    [~,var9] = find(strcmp(header,'LDL'));
    [~,var10] = find(strcmp(header,'NITRATOS'));
    [~,var12] = find(strcmp(header,'COLES-TEROL'));
    [~,var13] = find(strcmp(header,'DISLIPI-DEMIA'));
    [~,var11] = find(strcmp(header,'TRIGLICERIDEOS'));

    feat_remov = [var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13];
    feat_selec = setdiff([2:varFinal],feat_remov);

    features = data(:,feat_selec);
    feat_header = header(1,feat_selec);

end