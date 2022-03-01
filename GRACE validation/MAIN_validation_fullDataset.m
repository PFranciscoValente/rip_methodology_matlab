%%-----------------------------------------------------------------------
% MAIN FILE FOR VALIDATION OF THE GRACE MODEL IN THE FULL DATASET
% Author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

clc
clear all
close all
format compact
warning('off','all')


%% INPUTS
    
dataset = 'acs_lookafterrisk';
% events > type of end-point
% options: 'death' , 'death + myocardial infarction';
events = 'death';
% use_missing > use of patients with missing values
% options: 'yes', 'no'
use_missing = 'no'; 
% dataset_info > selection of datasets sources 
% options: 'all', 'stacruz', 'leiria', 'stacruz_nstemi', 'stacruz_nstemi'
dataset_info = 'all';

%% ======= VALIDATION OF THE GRACE MODEL IN THE DATASET  ==============

intervals = {'14days','30days','6months','1year'};

predictions = [];
true = [];

% evaluate GRACE model for the 4 periods (14d, 30d, 6m, 1y)
for i=1:size(intervals,2)
    
    % days_of_followUp> follow-up time required in order to the patients enter in the study
    % options: '14days', '30days', '6months', '1year'
    days_of_followUp = intervals{i}; 
    % time > period of time of events occurance
    time = intervals{i}

    %% PREPROCESSING
    
    % Get data
    [features,label,all_labels,feat_header,days_of_events] = data_preprocessing(events,time,days_of_followUp);
    % Features used in grace model:
    names_feat = {'idade', 'pressao sistolica', 'frequencia cardiaca', 'desvios st', 'biom. lesao cardiaca ', 'creatinina', 'paragem card. admiss.'};
    % Select features to be used
    selected_features = select_features(names_feat,feat_header);
    % Update dataset considering only the features of interest
    my_features_aux = features(:,selected_features);
    my_feat_header = feat_header(1,selected_features);

    % Choose only one dataset
    if ~isequal(dataset_info,'all')
        [~,idx_dataset]= find(strcmp(feat_header, 'DATASET'));
        if isequal(dataset_info,'stacruz')
            idx_select_data = find(features(:,idx_dataset)<3);
        elseif isequal(dataset_info,'stacruz_stemi')
            idx_select_data = find(features(:,idx_dataset)==2);
        elseif isequal(dataset_info,'stacruz_nstemi')
            idx_select_data = find(features(:,idx_dataset)==1);
        elseif isequal(dataset_info,'leiria')
            idx_select_data = find(features(:,idx_dataset)==3);
        end
        features = features(idx_select_data,:);
        label = label(idx_select_data,:);
    end
    
    %% USE ONLY PATIENTS WITH NO MISSING VALUES
    
    % death rate with patients with missing values
    rate_before = length(find(label==1))/length(label);
    
    % Choose only patients with no missing values
    if isequal(use_missing, 'no')
        [my_features_aux, idx_toRemove] = rmmissing(my_features_aux);
        label(idx_toRemove==1) = []; 
        all_label = all_labels(idx_toRemove==1,:);
        days_of_events(idx_toRemove==1) = []; 
    end
    
    % number of patients with no missing values
    number_patients = length(label)
    
    % death rate for patients without missing values
    rate_after = length(find(label==1))/length(label);
    deathRate_before_after = [rate_before ,rate_after]

    %%  COMPUTE GRACE RISK SCORE
    
    % 'short' > based on the model of in-hospital death - Granger
    % (original paper: "Predictors of Hospital Mortality in the Global Registry of Acute Coronary Events")
    
    % 'long' > based on the model of death 6 months after admission - Fox
    % (original paper: "Prediction of risk of death and myocardial infarction in the six months after presentation with acute coronary syndrome:
    % prospective multinational observational study (GRACE)")
    
    grace_outputs = grace_classifier(my_feat_header, my_features_aux, 'short', 'scores');
    [X,Y,T,auc_grace_short] = perfcurve(label,grace_outputs,1);
    grace_outputs = grace_classifier(my_feat_header, my_features_aux, 'long', 'scores');
    [X,Y,T,auc_grace_long] = perfcurve(label,grace_outputs,1);
    auc_short_long = [auc_grace_short , auc_grace_long]
    
    % GRACE RISK SCORE IN TERMS OF PROBABILITIES
    % convert the score (number of points) into a interval of [0,1] of risk of death
    grace_outputs = grace_classifier(my_feat_header, my_features_aux, 'short', 'probabilities');
    [X,Y,T,auc_grace_short] = perfcurve(label,grace_outputs,1);
    grace_outputs2 = grace_classifier(my_feat_header, my_features_aux, 'long', 'probabilities');
    [X,Y,T,auc_grace_long] = perfcurve(label,grace_outputs2,1);
    auc_short_long = [auc_grace_short , auc_grace_long]
    
    % save data about the 30 days period (the one used in our paper)
    if i==2
        predictions = grace_classifier(my_feat_header, my_features_aux, 'short', 'probabilities');
        true = label;
    end

    %% STRATIFY INTO LOW-RISK AND HIGH-RISK
    
    % the GRACE divide into tree categories (low, intermediate and high),
    % so it is necessary to rearrange it to only two categories
    
    % separation > rearrange of GRACE division into only two categories
    % options : 1 - low/intermediate - high, 2 - low - intermediate/high
    separation = 2;
    
    % as stratification depends on diagnostic feature as well, then remove
    % patients withouth diagnostic info
    diagnostico = features(:,select_features({'diagnóstico'},feat_header));
    diagnostico(idx_toRemove==1) = []; 
    [diagnostico, idx_toRemove] = rmmissing(diagnostico);
    label(idx_toRemove==1) = []; 
    
    % save data about the 30 days period (the one used in our paper)
    if i==2
       predictions(idx_toRemove==1) = []; 
       grace_rates_mortality(predictions', label, diagnostico) 
    end
    
    % discrimination metrics
    [gm_short, sens_short, spec_short, f1score_short, npv_short, ppv_short] = stratify_grace(grace_outputs, label, 'short', 'probabilities', diagnostico, separation);
    [gm_long, sens_long, spec_long, f1score_long, npv_long, ppv_long] = stratify_grace(grace_outputs, label, 'long', 'probabilities', diagnostico, separation);
    gm_short_long = [gm_short , gm_long]
    sens_short_long = [sens_short , sens_long]
    spec_short_long = [spec_short , spec_long]
    f1score_short_long = [f1score_short , f1score_long]
    npv_short_long = [npv_short , npv_long]
    ppv_short_long = [ppv_short , ppv_long]
    
    display('---------------------');
    
end


%% PLOT RISK VS MORTALITY (30 days)
% plot da taxa de mortalidade em função do GRACE risk

% obter taxa de mortalidade por grupo de risco
ranges = [0 0.01 0.02  0.03 0.04 0.06 0.10 0.15 0.20 ];
discretization = discretize(predictions,ranges);
rates = [];
intervals = unique(discretization);
sizes = [];
for bin = 1:length(intervals)
    idx = find(discretization==intervals(bin));
    mortality = true(idx);
    rate = sum(mortality)/length(mortality)*100;
    rates = [rates ; rate];  
    sizes = [sizes ; length(idx)];
end

% plot
if 1
    figure()
    plot(intervals,rates,'-o')
    % x ticks
    xticks(intervals)
    xticknames = {'[0-1]','[1-2]','[2-3]','[3-4]','[4-6]','[60-10]','[10-15]','[15-20]'};
    xticklabels(xticknames(intervals))
    % text 
    text(intervals,rates+3,num2cell(sizes))
    xlabel ('Risk predicted by GRACE (%)')
    ylabel ('Mortality rate (%)')
    ylim([0,100])
    title('Predicted 30-days risk of death by GRACE vs Mortality rate');
end


%% CALIBRATION PLOT
% plot da curva de calibraçao

% obter casos observados por quantile
nr_tt = 10;
quantiles = quantile(predictions,0:1/nr_tt:1);
x = [];
y=[];
for tt=1:nr_tt

    q_idx = find(predictions >= quantiles(tt) & predictions <= quantiles(tt+1));
    predictions(q_idx)';
    q_pat = mean(predictions(q_idx));
    q_dr = length(find(true(q_idx)==1))/length(true(q_idx));

    x = [x q_pat];
    y = [y q_dr];

end
X = x*100;
Y = y*100;

% slope and intercept
P = polyfit(x,y,1);
slope = P(1);
intercept = P(2);

% plot de calibração
figure()
max1 = max([max(X) max(Y)]);
max1 = max1+5;
plot([0 max1],[0 max1], 'Color',[0 0.4470 0.7410])
hold on
plot(X,Y, '.-', 'Color',[0.8500 0.3250 0.0980], 'MarkerSize', 10)    
hold on
plot(NaN,NaN,'display','', 'linestyle', 'none')
hold on
plot(NaN,NaN,'display','', 'linestyle', 'none')
hold off
xlim([0 max1]);
ylim([0 max1]);
h3 = legend('Ideal', 'Calibration', ['slope: ', num2str(round(slope,3))], ['intercept: ', num2str(round(intercept,3))], 'Location','southeast');    
xlabel('Predicted risk (%)');
ylabel('Mortality rate (%)');
title('GRACE (clinical risk model)');


