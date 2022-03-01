%%-----------------------------------------------------------------------
% MAIN FILE - LOOKAFTERRISK DATA - PROPOSED APPROACH VS STANDARD ML
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

clc
clear all
close all force
format compact
warning('off','all')
patternnet([]);
% rng('default')

%% INPUTS

% use_missing > use of patients with missing values
% options: 'yes', 'no'
use_missing = 'yes'; 

% method_threshold > method used to create the decision rules
method_threshold = 'normalized distances';

% METHODS FOR MISSING IMPUTATION : see treat_missing_data function for more information
% method_ordinal > method used for data imputation in ordinal variables
method_ordinal = 'mode knn';
% method_binary > method used for data imputation in binary variables
method_binary = 'mode knn';
% method_binary = 'lower';
% method_continuous > method used for data imputation in continuous variables
method_continuous = 'mean knn';

% BALANCING
% balancing > undersampling of the negative class
% options: 'no' (no balancing), 'simple', 'clustering'
% 'simple': random selection of negative samples, 'clustering': clustering-based selection of negative samples
% balancing = 'simple';
% ratio_balancing > ratio negative-to-positive samples (only used if balancing is not 'no')
% eg: ratio=3, for each positive sample, it selects three negative ones
ratio_balancing = 1.5; 


%% DATA LOAD AND PREPROCESSING

% 1. Load lookafterrisk data 
% some consideration may be changed inside the function
% e.g., use a different time of follow-up or use myocardial reinfarction as end-point
[features, label, my_feat_header, categorical_vector, features_type] = data_lookafterrisk;

% 2. Remove patients with missing data if use_missing='no'
if isequal(use_missing, 'no')
    [features, idx_toRemove] = rmmissing(features);
    label(idx_toRemove==1) = []; 
end

%% =========== MONTE CARLO CROSS VALIDATION ===========

% Create necessary vectors
all_gm_train_mine = [];
all_auc_train_mine = [];
all_gm_test_mine = [];
all_auc_test_mine = [];
all_npv_test_mine = [];
all_ppv_test_mine = [];
all_ppv_train_mine = [];
all_npv_train_mine = [];
all_gm_train_lr = [];
all_auc_train_lr = [];
all_gm_test_lr = [];
all_auc_test_lr = [];
all_npv_test_lr = [];
all_ppv_test_lr = [];
all_ppv_train_lr = [];
all_npv_train_lr = [];
all_gm_train_nn = [];
all_auc_train_nn = [];
all_gm_test_nn = [];
all_auc_test_nn = [];
all_npv_test_nn = [];
all_ppv_test_nn = [];
all_ppv_train_nn = [];
all_npv_train_nn = [];
all_sens_test_nn = [];
all_spec_test_nn = [];
all_sens_test_lr = [];
all_spec_test_lr = [];
all_sens_test_mine = [];
all_spec_test_mine = [];
all_f1_test_mine = [];
all_f1_test_lr = [];
all_f1_test_nn = [];
all_thresholds_mine = [];
all_thresholds_lr = [];
all_thresholds_nn = [];
all_test_x_nn = [];
all_test_y_nn = [];
all_test_x_lr = [];
all_test_y_lr = [];
all_test_x_mine = [];
all_test_y_mine = [];
all_predictions =[];
all_true = [];
all_thresholds = [];
all_neg_means = [];
all_pos_means = [];
reliability_rates = [];
all_sizes = [];

% Number of iterations (runs) of Monte-Carlo cross validation
nr_iter = 1:10;

for iter=1:length(nr_iter)

    display('__________________________')
    run = nr_iter(iter)
        
    rng(iter*5-3*iter); 
    % random generator that is used to obtain reproducible resuts 
    % - note: in the research paper was not used this generator, so the results will not be exactly the same
    
    % division into train and test datasets
    [feat_train, feat_test, label_train, label_test] = division_train_test(features, label);
    
    %% RUN MODELS
    
    % metodos a experimentar simultaneamente
    % codigo pode ser alterado para correr só um dos métodos ou adicionar outros
    % type_label define a abordagem: 'rules' - abordagem proposta, 'standard' - machine learning tradicional
    % clf define o classificador para gerar os prediction models nas abordagens: 'nn' - artificial neural network, 'lr' - logistic regression
    
    for method=1:3
    
        if method==1 % abordagem proposta
            balancing = 'simple'; % definir tipo de clustering
            clf = 'nn'; type_label = 'rules';
            display('computing method 1...')
            
        else % machine learning standard (ann e lr)
            balancing = 'no';
            if method==2
                clf = 'lr'; type_label = 'standard';
                display('computing method 2...')
            elseif method==3
                clf = 'nn'; type_label = 'standard';
                display('computing method 3...')
            end  
        end

        %% FINAL PREPROCESSING

        % impute missing data if use_missing = 'yes'
        if isequal(use_missing, 'yes')
            [feat_train,feat_test] = treat_missing_data(feat_train,feat_test,my_feat_header,method_binary, method_ordinal, method_continuous, 10);
        end


%         % VARIABLES TO USE
%         % To train the rules
%         feat_train = all_feat_train(:,my_idx_feat_train);
%         feat_test = all_feat_test(:,my_idx_feat_train);

        % To be used as rules
%         rules_header  = my_feat_header(1,my_idx_feat_rules);
%         feat_train_rules = all_feat_train(:,my_idx_feat_rules);
%         feat_test_rules = all_feat_test(:,my_idx_feat_rules);

        
        if method == 1
            
            %% ======== CREATION OF DECISION RULES ==========

            % FIND VIRTUAL PATIENTS AND THRESHOLDS FOR RULES 
            % (see function for more details)
            [all_rules_outputs, virtual_negatives_rules, virtual_positives_rules, d_thresholds_rules, rules_geom_means] = rules_normalizedDistances(feat_train,label_train);

            % EVALUATION OF RULES CORRECTENESS IN TRAINING DATASET
            % > for each patient, for each feature, it has a value of 1 if the rule
            % is correct for that patient and a value of 0 if it is wrong
            all_rules_acceptance = fix(label_train == all_rules_outputs);

            % APLY THE DECISION RULES TO TESTING DATASET 
            % > 'attributed_classes' is the equivalent of 'all_rules_outputs' but for the testing data 
            attributed_classes = apply_normalizedDistances(feat_test, virtual_negatives_rules, virtual_positives_rules);
 
            % BALANCEAMENTO
            % nota: o balanceamento só é necessário para treinar os modelos
            % de previsão de aceitação das regras. de resto, para as outras
            % tarefas, (criação das regras, etc) são usados dados sem
            % balanceamento. os dados que ficam de fora após balanceamento
            % (rem_rules_outputs, e posteriormente as consequentes
            % clf_rem_outputs mais abaixo) são guardadas pois serão
            % utilizados para criar os modelos de calibração
            % rem = remaining
            idx_positive = find(label_train==1);
            idx_negative = find(label_train==0);
            positive_size = length(idx_positive);
            positive_data = feat_train(idx_positive,:);
            negative_data = feat_train(idx_negative,:);
            select_negativeSize = round(ratio_balancing*positive_size);
            my_negative_data = negative_data(1:select_negativeSize,:);
            rem_negative_data = negative_data(select_negativeSize+1:end,:); % dados treino não usados no balanceamento
            new_feat_train = [positive_data ; my_negative_data]; %dados treino balanceados
            new_label_train = [ones(1,positive_size) , zeros(1,select_negativeSize)]'; %label treino balanceado
            [~,~,index_rem] = intersect(rem_negative_data,feat_train,'rows'); % indexes dos dados não usados no balanceamento no dataset inicial
            index_used = setdiff(1:size(label_train),index_rem); % indexes dos dados usados no balanceamento no dataset inicial
            rem_rules_outputs = all_rules_outputs(index_rem,:); % outputs das regras nos dados não usados no balanceamento
            rules_acceptance = all_rules_acceptance(index_used,:);% aceitação das regras nos dados usados no balanceamento
            rules_outputs = all_rules_outputs(index_used,:); % outputs das regras nos dados usados no balanceamento


            %% ======== PREDICTION OF MORTALITY RISK AND ITS RELIABILITY  ========
            
            % train and test the prediction models
            % clf_outputs > previsoes de aceitação/correção das regras para cada paciente 
             [clf_train_outputs, clf_test_outputs, clf_rem_outputs] = ...
               train_test_classifier(new_feat_train,feat_test,rules_acceptance, clf, type_label, rem_negative_data);

        elseif isequal(type_label,'standard')
            
            % nota: aqui não foi feito balanceamento
            % apenas se treina e testa os classificadores
            % clf_outputs > previsoes de aceitação/correção das regras para cada paciente 
            [clf_train_outputs, clf_test_outputs] = ...
                train_test_classifier(feat_train,feat_test, label_train, clf, type_label);
            
            % os vectores rem (remaining) não são usados, só inicializei para correr as funções de performance sem dar problemas
            % porque as funções de performance são usadas tanto para a abordagem proposta como para machine learning tradicional
            clf_rem_outputs = [];
            rem_rules_outputs = [];
            
        end
  
        
        % EVALUATE PERFORMANCE OF MODELS IN TRAINING AND TESTING
        
        % Note: if we want to evaluate if each individual element is
        % correct in the training of features in the proposed approach, we
        % compare clf_train_outputs with rules_outputs
       
        % performance train (see function for more details)
        % calibration model is also computed in this function
        if method == 1 % abordagem proposta
            [auc_train, optThreshold, spec_train, sens_train, geom_mean_train, calibrator, ppv_train, npv_train] = ...
                performance_train(new_label_train, clf_train_outputs, rules_outputs, type_label, clf_rem_outputs, rem_rules_outputs);
        else % machine learning tradicional
            [auc_train, optThreshold, spec_train, sens_train, geom_mean_train, calibrator, ppv_train, npv_train] = ...
                performance_train(label_train, clf_train_outputs, rules_outputs, type_label, clf_rem_outputs, rem_rules_outputs);
        end
        

        % display do threshold de categorização dos pacientes em high risk or low risk , i.e., da binarização do risco
%         display(['categorization threshold: ', num2str(optThreshold)]);
        
        % performance test (see function for more details) 
        [sens_test, spec_test, geom_mean_test, prec_test, f1score_test, ppv_test, npv_test, confusion_matrix_test, auc_test, p_kw_test, ...
            reliability_values, rates_reliability, pos_means, neg_means, predictions, predicted_events, observed_events, nr_instances_quant_reliab] = ...
            performance_test(label_test, clf_test_outputs, attributed_classes, type_label, optThreshold, calibrator);

        % Plot reliability vs predictions
        % figure()
        % scatter(reliability,predictions)
        % xlabel('reliability estimate')
        % ylabel('mortality risk')
  

        if 0 % show results in each run (put "if 1" to show)
            
            display(['method', num2str(method)])
            display(['classifier', clf])
            
            display ('....train performance.....')
            display(['     AUC   ','opt threshold   '])
            display([auc_train, optThreshold])

            display ('....test performance.....')
            display(['     SENS  ','    SPEC   ',' GEOM_MEAN   ', ' AUC   '])
            display([sens_test, spec_test, geom_mean_test, auc_test])
        end

        
        % SAVE RESULTS FOR ALL THE METHODS
        
        if method==1
            all_gm_train_mine = [all_gm_train_mine ; geom_mean_train];
            all_auc_train_mine = [all_auc_train_mine ; auc_train];
            all_gm_test_mine = [all_gm_test_mine ; geom_mean_test];
            all_auc_test_mine = [all_auc_test_mine ; auc_test];
            all_ppv_train_mine = [all_ppv_train_mine ; ppv_train];
            all_npv_train_mine = [all_npv_train_mine ; npv_train];
            all_ppv_test_mine = [all_ppv_test_mine ; ppv_test];
            all_npv_test_mine = [all_npv_test_mine ; npv_test];
            all_f1_test_mine = [all_f1_test_mine ; f1score_test];
            all_sens_test_mine = [all_sens_test_mine ; sens_test];
            all_spec_test_mine = [all_spec_test_mine ; spec_test];
            all_thresholds_mine = [all_thresholds_mine ; optThreshold];
            all_test_x_mine = [all_test_x_mine ; predicted_events];
            all_test_y_mine = [all_test_y_mine ; observed_events];
            all_predictions =[all_predictions ; predictions];
            all_true = [all_true ; label_test];
            all_thresholds = [all_thresholds ; d_thresholds_rules];
            all_pos_means = [all_pos_means ; pos_means];
            all_neg_means = [all_neg_means ; neg_means];
            reliability_rates = [reliability_rates ; rates_reliability];
            all_sizes = [all_sizes ; nr_instances_quant_reliab];
        elseif method==2
            all_gm_train_lr = [all_gm_train_lr ; geom_mean_train];
            all_auc_train_lr = [all_auc_train_lr ; auc_train];
            all_gm_test_lr = [all_gm_test_lr ; geom_mean_test];
            all_auc_test_lr = [all_auc_test_lr ; auc_test];
            all_ppv_train_lr = [all_ppv_train_lr ; ppv_train];
            all_npv_train_lr = [all_npv_train_lr ; npv_train];
            all_ppv_test_lr = [all_ppv_test_lr ; ppv_test];
            all_npv_test_lr = [all_npv_test_lr ; npv_test];
            all_sens_test_lr = [all_sens_test_lr ; sens_test];
            all_spec_test_lr = [all_spec_test_lr ; spec_test];
            all_f1_test_lr = [all_f1_test_lr ; f1score_test];
            all_thresholds_lr = [all_thresholds_lr ; optThreshold];
            all_test_x_lr = [all_test_x_lr ; predicted_events];
            all_test_y_lr = [all_test_y_lr ; observed_events];
        elseif method==3
            all_gm_train_nn = [all_gm_train_nn ; geom_mean_train];
            all_auc_train_nn = [all_auc_train_nn ; auc_train];
            all_gm_test_nn = [all_gm_test_nn ; geom_mean_test];
            all_auc_test_nn = [all_auc_test_nn ; auc_test];
            all_ppv_train_nn = [all_ppv_train_nn ; ppv_train];
            all_npv_train_nn = [all_npv_train_nn ; npv_train];
            all_ppv_test_nn = [all_ppv_test_nn ; ppv_test];
            all_npv_test_nn = [all_npv_test_nn ; npv_test];
            all_sens_test_nn = [all_sens_test_nn ; sens_test];
            all_spec_test_nn = [all_spec_test_nn ; spec_test];
            all_f1_test_nn = [all_f1_test_nn ; f1score_test];
            all_thresholds_nn = [all_thresholds_nn ; optThreshold];
            all_test_x_nn = [all_test_x_nn ; predicted_events];
            all_test_y_nn = [all_test_y_nn ; observed_events];
        end

    end

end


%% ============= FINAL RESULTS - DISCRIMINATION METRICS > summary of all Monte Carlo cross validation runs =============================

% Legend
% Train: results in training dataset
% Test: results in testing dataset
% Proposed: proposed approach 
% LR: standard logistic regression model
% NN: standard neural network model
% GM: geometric mean of specificity and sensitivity
% AUC: area under the ROC curve
% NPV: negative predictive value
% PPV: positive predictive value
% SENS: sensitivity
% SPEC: specificity

% RESULTS OF EACH MODEL, INDIVIDUALLY

display('_________________________________________________')
display('---------FINAL RESULTS--------')
display(' ')
display (':::::::::::: RESULTS TRAIN ::::::::::::')

display ('.... PROPOSED GM TRAIN .....')
display([mean(all_gm_train_mine) , confidence_interval(all_gm_train_mine)'])
display ('.... PROPOSED AUC TRAIN .....')
display([mean(all_auc_train_mine) , confidence_interval(all_auc_train_mine)'])
display ('.... PROPOSED NPV TRAIN .....')
display([nanmean(all_npv_train_mine) , confidence_interval(all_npv_train_mine)'])
display ('.... PROPOSED PPV TRAIN .....')
display([mean(all_ppv_train_mine) , confidence_interval(all_ppv_train_mine)'])
display ('.... LR GM TRAIN .....')
display([mean(all_gm_train_lr) , confidence_interval(all_gm_train_lr)'])
display ('.... LR AUC TRAIN .....')
display([mean(all_auc_train_lr) , confidence_interval(all_auc_train_lr)'])
display ('.... LR NPV TRAIN .....')
display([nanmean(all_npv_train_lr) , confidence_interval(all_npv_train_lr)'])
display ('.... LR PPV TRAIN .....')
display([mean(all_ppv_train_lr) , confidence_interval(all_ppv_train_lr)'])
display ('.... NN GM TRAIN .....')
display([mean(all_gm_train_nn) , confidence_interval(all_gm_train_nn)'])
display ('.... NN AUC TRAIN .....')
display([mean(all_auc_train_nn) , confidence_interval(all_auc_train_nn)'])
display ('.... NN NPV TRAIN .....')
display([nanmean(all_npv_train_nn) , confidence_interval(all_npv_train_nn)'])
display ('.... NN PPV TRAIN .....')
display([mean(all_ppv_train_nn) , confidence_interval(all_ppv_train_nn)'])

display(' ')
display (':::::::::::: RESULTS TEST ::::::::::::')

display ('.... PROPOSED GM TEST .....')
display([mean(all_gm_test_mine) , confidence_interval(all_gm_test_mine)'])
display ('.... PROPOSED AUC TEST .....')
display([mean(all_auc_test_mine) , confidence_interval(all_auc_test_mine)'])
display ('.... PROPOSED NPV TEST .....')
display([nanmean(all_npv_test_mine) , confidence_interval(all_npv_test_mine)'])
display ('.... PROPOSED PPV TEST .....')
display([mean(all_ppv_test_mine) , confidence_interval(all_ppv_test_mine)'])
display ('.... PROPOSED F1 SCORE TEST .....')
display([mean(all_f1_test_mine) , confidence_interval(all_f1_test_mine)'])
display ('.... PROPOSED SENS TEST .....')
display([mean(all_sens_test_mine) , confidence_interval(all_sens_test_mine)'])
display ('.... PROPOSED SPEC TEST .....')
display([mean(all_spec_test_mine) , confidence_interval(all_spec_test_mine)'])

display ('::::::::::::::::::::::')

display ('.... LR GM TEST .....')
display([mean(all_gm_test_lr) , confidence_interval(all_gm_test_lr)'])
display ('.... LR AUC TEST .....')
display([mean(all_auc_test_lr) , confidence_interval(all_auc_test_lr)'])
display ('.... LR NPV TEST .....')
display([nanmean(all_npv_test_lr) , confidence_interval(all_npv_test_lr)'])
display ('.... LR PPV TEST .....')
display([mean(all_ppv_test_lr) , confidence_interval(all_ppv_test_lr)'])
display ('.... LR F1 SCORE TEST .....')
display([mean(all_f1_test_lr) , confidence_interval(all_f1_test_lr)'])
display ('.... LR SENS TEST .....')
display([mean(all_sens_test_lr) , confidence_interval(all_sens_test_lr)'])
display ('.... LR SPEC TEST .....')
display([mean(all_spec_test_lr) , confidence_interval(all_spec_test_lr)'])

display ('::::::::::::::::::::::')

display ('.... NN GM TEST.....')
display([mean(all_gm_test_nn) , confidence_interval(all_gm_test_nn)'])
display ('.... NN AUC TEST .....')
display([mean(all_auc_test_nn) , confidence_interval(all_auc_test_nn)'])
display ('.... NN NPV TEST .....')
display([nanmean(all_npv_test_nn) , confidence_interval(all_npv_test_nn)'])
display ('.... NN PPV TEST .....')
display([nanmean(all_ppv_test_nn) , confidence_interval(all_ppv_test_nn)'])
display ('.... NN F1 SCORE TEST .....')
display([nanmean(all_f1_test_nn) , confidence_interval(all_f1_test_nn)'])
display ('.... NN SENS TEST .....')
display([nanmean(all_sens_test_nn) , confidence_interval(all_sens_test_nn)'])
display ('.... NN SPEC TEST .....')
display([mean(all_spec_test_nn) , confidence_interval(all_spec_test_nn)'])


% COMPARING OF RESULTS BETWEEN MODELS (DELTAS)
% differences between the results of models, considering each run
% suggested by a reviewer of the paper

display('_________________________________________________')
display(' ')
display (':::::::::::: DELTAS TEST ::::::::::::')
% deltas of proposed approach and logistic regression
delta_gm_lr_train = all_gm_train_mine-all_gm_train_lr;
delta_gm_lr_test = all_gm_test_mine-all_gm_test_lr;
delta_auc_lr_train = all_auc_train_mine-all_auc_train_lr;
delta_auc_lr_test = all_auc_test_mine-all_auc_test_lr;
delta_ppv_lr_train = all_ppv_train_mine-all_ppv_train_lr;
delta_ppv_lr_test = all_ppv_test_mine-all_ppv_test_lr;
delta_npv_lr_train = all_npv_train_mine-all_npv_train_lr;
delta_npv_lr_test = all_npv_test_mine-all_npv_test_lr;
% deltas of proposed approach and artificial neural network
delta_gm_nn_train = all_gm_train_mine-all_gm_train_nn;
delta_gm_nn_test = all_gm_test_mine-all_gm_test_nn;
delta_auc_nn_train = all_auc_train_mine-all_auc_train_nn;
delta_auc_nn_test = all_auc_test_mine-all_auc_test_nn;
delta_ppv_nn_train = all_ppv_train_mine-all_ppv_train_nn;
delta_ppv_nn_test = all_ppv_test_mine-all_ppv_test_nn;
delta_npv_nn_train = all_npv_train_mine-all_npv_train_nn;
delta_npv_nn_test = all_npv_test_mine-all_npv_test_nn;
% MEAN RESULTS ACROSS ALL THE MONTE CARLO CV RUNS
display ('.... DELTA GM LR TEST .....')
display([mean(delta_gm_lr_test) , confidence_interval(delta_gm_lr_test)'])
display ('.... DELTA AUC LR TEST .....')
display([mean(delta_auc_lr_test) , confidence_interval(delta_auc_lr_test)'])
display ('.... DELTA PPV LR TEST .....')
display([mean(delta_ppv_lr_test) , confidence_interval(delta_ppv_lr_test)'])
display ('.... DELTA NPV LR TEST .....')
display([mean(delta_npv_lr_test) , confidence_interval(delta_npv_lr_test)'])
display ('.... DELTA GM NN TEST .....')
display([mean(delta_gm_nn_test) , confidence_interval(delta_gm_nn_test)'])
display ('.... DELTA AUC NN TEST .....')
display([mean(delta_auc_nn_train) , confidence_interval(delta_auc_nn_train)'])
display ('.... DELTA PPV LR TEST .....')
display([mean(delta_ppv_nn_test) , confidence_interval(delta_ppv_nn_test)'])
display ('.... DELTA NPV LR TEST .....')
display([nanmean(delta_npv_nn_test) , confidence_interval(delta_npv_nn_test)'])

% CATEGORIZATION THRESHOLDS
% mean thresholds de categorização dos pacientes em high risk or low risk , i.e., da binarização do risco
display('_________________________________________________')
display(' ')
display (':::::::::::: CATORIZATION THRESHOLDS ::::::::::::')
display ('.... PROPOSED .....')
display([mean(all_thresholds_mine) , confidence_interval(all_thresholds_mine)'])
display ('.... LR .....')
display([mean(all_thresholds_lr) , confidence_interval(all_thresholds_lr)'])
display ('.... NN .....')
display([mean(all_thresholds_nn) , confidence_interval(all_thresholds_nn)'])


%% =============  CALIBRATION PLOTS =============================

calibration_plot(all_test_x_mine,all_test_y_mine, 'Proposed approach')
calibration_plot(all_test_x_lr,all_test_y_lr, 'Logistic regression')
calibration_plot(all_test_x_nn,all_test_y_nn, 'Neural network')


%% =============  DECISION RULES THRESHOLDS =============================
% Thersholds usados para dividir as features e criar as regras

if 1
    
    display (':::::::::::: DECISION RULES THRESHOLDS ::::::::::::')
    for i=1:length(my_feat_header)
        if strcmp(features_type{i},'continuous')
            display([my_feat_header{i}, ': ', num2str(mean(all_thresholds(:,i))), ' +- ', num2str(std(all_thresholds(:,i)))])
        else
            display([my_feat_header{i}, ': ', num2str(mean(all_thresholds(:,i))), ' +- ', num2str(std(all_thresholds(:,i)))])     
        end
    end

end
%% SAVE VARIABLES
% save vectors with results

% save_all_auc = input('Do you want save the variable all_auc proposed? [Y]: ','s');
% if isequal(save_all_auc,'Y')
%     filename = input('With which name do you want to save? ','s');
%     name = [filename '.mat'];
%     save(name, 'all_auc_test_mine');
% end

% save_all_gm = input('Do you want save the variable all_gm proposed? [Y]: ','s');
% if isequal(save_all_gm,'Y')
%     filename = input('With which name do you want to save? ','s');
%     name = [filename '.mat'];
%     save(name, 'all_gm_test_mine');
% end

% save_all_auc = input('Do you want save the variable all_auc lr? [Y]: ','s');
% if isequal(save_all_auc,'Y')
%     filename = input('With which name do you want to save? ','s');
%     name = [filename '.mat'];
%     save(name, 'all_auc_test_lr');
% end

% save_all_gm = input('Do you want save the variable all_gm lr? [Y]: ','s');
% if isequal(save_all_gm,'Y')
%     filename = input('With which name do you want to save? ','s');
%     name = [filename '.mat'];
%     save(name, 'all_gm_test_lr');
% end
 
% save_all_auc = input('Do you want save the variable all_auc nn? [Y]: ','s');
% if isequal(save_all_auc,'Y')
%     filename = input('With which name do you want to save? ','s');
%     name = [filename '.mat'];
%     save(name, 'all_auc_test_nn');
% end

% save_all_gm = input('Do you want save the variable all_gm nn? [Y]: ','s');
% if isequal(save_all_gm,'Y')
%     filename = input('With which name do you want to save? ','s');
%     name = [filename '.mat'];
%     save(name, 'all_gm_test_nn');
% end

% plot_reliability = input('Do you want display the reliability plot? [Y]: ','s');
% if isequal(plot_reliability,'Y')
%     plots_results('reliability',reliability_rates)
% end

% save_reliability_rates = input('Do you want save the variable reliability_rates? [Y]: ','s');
% if isequal(save_reliability_rates,'Y')
%     filename = input('With which name do you want to save? ','s');
%     name = [filename '.mat'];
%     save(name, 'reliability_rates');
% end

%% Aditional assessment (are rules meaningful?)
% observe importance of balancing step

% index_pos = find(all_true==1);
% index_neg = find(all_true==0);
% % true positives
% idx_pos_neg = all_neg_means(index_pos);
% idx_pos_pos = all_pos_means(index_pos);
% median(idx_pos_neg);
% median(idx_pos_pos);
% % true negatives
% idx_neg_neg = all_neg_means(index_neg);
% idx_neg_pos = all_pos_means(index_neg);
% median(idx_neg_neg);
% median(idx_neg_pos);