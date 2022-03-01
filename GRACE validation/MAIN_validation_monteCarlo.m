%%-----------------------------------------------------------------------
% MAIN FILE FOR VALIDATION OF THE GRACE MODEL AT 30days THROUGH MONTE CARLO 
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
use_missing = 'yes'; 
% METHODS FOR MISSING IMPUTATION : see treat_missing_data function for more information
% method_ordinal > method used for data imputation in ordinal variables
method_ordinal = 'mode knn';
% method_binary > method used for data imputation in binary variables
method_binary = 'mode knn';
% method_binary = 'lower';
% method_continuous > method used for data imputation in continuous variables
method_continuous = 'mean knn';
% dataset_info > selection of datasets sources 
% options: 'all', 'stacruz', 'leiria', 'stacruz_nstemi', 'stacruz_nstemi'
dataset_info = 'all';

%% ======= VALIDATION OF THE GRACE MODEL IN THE DATASET  ==============

intervals = {'30days'};

predictions = [];
true = [];

gm = [];
auc = [];
npv = [];
ppv = [];
all_test_predictedEvents = [];
all_test_observedEvents = [];

% days_of_followUp> follow-up time required in order to the patients enter in the study
% options: '14days', '30days', '6months', '1year'
days_of_followUp = intervals{1}; 
% time > period of time of events occurance
time = intervals{1}

%% PREPROCESSING

% Get data
[features,label,all_labels,feat_header,days_of_events] = data_preprocessing(events,time,days_of_followUp);
% Features used in grace model:
names_feat = {'diagnóstico', 'idade', 'pressao sistolica', 'frequencia cardiaca', 'desvios st', 'biom. lesao cardiaca ', 'creatinina', 'paragem card. admiss.'};
% Select features to be used
selected_features = select_features(names_feat,feat_header);
% Update dataset considering only the features of interest
my_features_aux = features(:,selected_features);
my_feat_header = feat_header(1,selected_features);

diag_info = select_features({'diagnóstico'},feat_header);
diagnostico = features(:,diag_info);


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

% number of Monte Carlo cross validation runs
nr_runs= 5
runs = 1:nr_runs;

for iter=1:length(runs)
    
    run = iter
    
    rng('shuffle');
    rng(iter*5-3*iter)
    % random generator that is used to obtain reproducible resuts 
    % - note: in the research paper was not used this generator, so the results will not be exactly the same
    % division into train and test dataseets
    
    % division into train and test datasets
    [all_feat_train, all_feat_test, label_train, label_test] = division_train_test(my_features_aux, label);

    % final preprocessing
    [all_feat_train,all_feat_test] = treat_missing_data(all_feat_train,all_feat_test,my_feat_header,method_binary, method_ordinal, method_continuous, 10);

    feat_train = all_feat_train(:,2:end);
    feat_test = all_feat_test(:,2:end);
    diag_test = all_feat_test(:,1);

    %%  COMPUTE GRACE RISK SCORE

    % 'short' > based on the model of in-hospital death - Granger
    % (original paper: "Predictors of Hospital Mortality in the Global Registry of Acute Coronary Events")

    % 'long' > based on the model of death 6 months after admission - Fox
    % (original paper: "Prediction of risk of death and myocardial infarction in the six months after presentation with acute coronary syndrome:
    % prospective multinational observational study (GRACE)")

    headers =my_feat_header(2:end);

    % GRACE RISK SCORE IN TERMS OF PROBABILITIES
    % convert the score (number of points) into a interval of [0,1] of risk of death
    grace_outputs = grace_classifier(headers, feat_test, 'short', 'probabilities');
    [X,Y,T,auc_grace_short] = perfcurve(label_test,grace_outputs',1);
    grace_outputs2 = grace_classifier(headers, feat_test, 'long', 'probabilities');
    [X2,Y2,T2,auc_grace_long] = perfcurve(label_test,grace_outputs2,1);
    auc_short_long = [auc_grace_short , auc_grace_long];
    
    auc = [auc , auc_grace_short];

    % GEOMETRIC MEAN

    % the GRACE divide into tree categories (low, intermediate and high),
    % so it is necessary to rearrange it to only two categories

    % separation > rearrange of GRACE division into only two categories
    % options : 1 - low/intermediate - high, 2 - low - intermediate/high
    separation = 1;
    
    [gm_short, sens_short, spec_short, f1score_short, npv_short, ppv_short] = stratify_grace(grace_outputs2, label_test, 'short', 'probabilities', diag_test, separation);
    gm = [gm, gm_short];

    % NEGATIVE AND POSITIVE PREDICTIVE VALUES
    
    [minValue,closestIndex] = min(abs(Y-0.8)); % fix sensitivity on 80%
    optThreshold = T(closestIndex);
    
    binary_predictions = double(grace_outputs>= optThreshold);
    true = label_test';
    
    % get ppv and npv for fixed sensitivity
    [~, ~, ~, ~, ~, ppv_run, npv_run] = discrimination_metrics(binary_predictions, true);
    npv = [npv, npv_run];
    ppv = [ppv, ppv_run];

    
    % CALIBRATION VALUES (PREDICTED RISK VS OBSERVED ONE)
    % to be used to build the calibration plot

    predictions = grace_outputs;
    true = label_test;
    nr_quantiles = 10;
    quantiles = quantile(predictions,0:1/nr_quantiles:1);
    
    predicted_events = [];
    observed_events = [];
    
    for iter_quantile=1:nr_quantiles
        
        quantile_idx = find(predictions >= quantiles(iter_quantile) & predictions <= quantiles(iter_quantile+1)); % idx de pacientes com risk incluido no quantile atual
        quantile_mean_risk = mean(predictions(quantile_idx)); % risco predito médio (predicted mortality) dos pacientes incluidos no quantile
        quantile_observed_events = length(find(true(quantile_idx)==1))/length(true(quantile_idx)); % taxa de eventos positivos (observed mortality) dos pacientes incluidos no quantile
        
        predicted_events = [predicted_events, quantile_mean_risk];
        observed_events = [observed_events, quantile_observed_events];
        
    end

    all_test_predictedEvents = [all_test_predictedEvents ; predicted_events];
    all_test_observedEvents = [all_test_observedEvents ; observed_events];
    
end


%% FINAL RESULTS

display (':::::::::::: RESULTS TEST ::::::::::::')
display ('.... GRACE GM TEST .....')
display([mean(gm) , confidence_interval(gm)'])
display ('.... GRACE AUC TEST .....')
display([mean(auc) , confidence_interval(auc)'])
display ('.... GRACE NPV TEST .....')
display([mean(npv) , confidence_interval(npv)'])
display ('.... GRACE PPV TEST .....')
display([mean(ppv) , confidence_interval(ppv)'])

% CALIBRATION PLOT
calibration_plot(all_test_predictedEvents,all_test_observedEvents, 'GRACE (clinical risk model)')

%% Save variables
% save('auc_grace.mat', 'auc');
% save('gm_grace.mat', 'gm');
% save('npv_grace.mat', 'npv');
% save('ppv_grace.mat', 'ppv');

