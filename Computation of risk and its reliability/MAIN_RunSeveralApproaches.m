%%-----------------------------------------------------------------------
% MAIN FILE USED FOR COMPUTATION OF SEVERAL APPROACHES THAT WERE
% CONSIDERING (the reliability analysis is not addressed here)
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

clc
clear all
% close all force
format compact
warning('off','all')
% patternnet([]);
% rng('default')

%% 1. SELECIONAR DATASET

[features, label, my_feat_header, categorical_vector, features_type] = loadDataSet;

%% 2. SELECIONAR MÉTODOS A UTILIZAR

[modelsToUse, header_modelsToUse] = selectMethods;

% SELECIONAR TIPO DE REGRAS (if applicable)
[modelsToUse, header_modelsToUse] = selectRules(modelsToUse, header_modelsToUse); % fazer update com info das rules

%% 3. OUTRAS OPÇOES (normalização, balanceamento e uso de missing data)

[modelsToUse, header_modelsToUse] = selectMoreOptions(modelsToUse, header_modelsToUse);

% Choose only patients with no missing values?
[features, label] = remove_missing(modelsToUse, header_modelsToUse, features, label);

%% 4. CALCULAR PREVISOES

[~,idx_useMissingTest] = find(strcmpi(header_modelsToUse,'missing_noUse_inTest')==1);
use_missing_test = modelsToUse(1,idx_useMissingTest);

% escolher parametros da validação Monte-Carlo
% (numero de runs e racio de hould-out)
prompt = {'Selecionar numero de runs', 'Hould-out rate'};
dlgtitle = 'Número de métodos a utilizar';
dims = [1 75];
definput = {'10', '0.2'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

nr_runs = str2num(answer{1});

if isequal(use_missing_test{1}, 'no')  % pipeline normal
   
    % vetor onde vao ser guardados os resultados
    all_results = cell(nr_runs,size(modelsToUse,1));
    all_gm_rules = cell(nr_runs,size(modelsToUse,1));

    for iter=1:nr_runs

        iter

        % divide data into train and test datasets
        [feat_train, feat_test, label_train, label_test] = division_train_test(features, label);
        % impute missing data (if applicable)
        [feat_train, feat_test] = impute_missing(modelsToUse, header_modelsToUse, feat_train, feat_test, features_type);

        for model=1:size(modelsToUse,1)

            % COMPUTE EACH MODEL

            % normalize data (if applicable)
            [my_feat_train, my_feat_test, norm_mu, norm_sigma] = normalize_data(modelsToUse, header_modelsToUse, feat_train, feat_test, model);

            % balance data (if applicable)
            [my_feat_train, my_label_train, rem_negative_data] = balance_data(modelsToUse, header_modelsToUse, my_feat_train, label_train, model);

            % compute each model(perform_prediction is basically where the
            % magic happens - it is where the most important parts of the
            % methodology are performed)
            
            my_model = modelsToUse(model,:);
            [results, virtual_negatives_rules, virtual_positives_rules, rules_geom_means, attributed_classes] = perform_prediction(my_model, header_modelsToUse, my_feat_train, my_feat_test, my_label_train, label_test, rem_negative_data);
            
            % save results
            all_results{iter,model} = results;
            all_gm_rules{iter,model} =  rules_geom_means;

        end

    end

    %RESUME OF RESULTS
    
    show_results(all_results) % AUC and Geometric mean results
    show_mean_gm(all_gm_rules) % Geometric means of individual rules

    % curvas calibração
%     auxiliar_calib( all_results{1,1}.predictions.test,label_test)
%     auxiliar_calib( all_results{1,2}.predictions.test,label_test)
%     auxiliar_calib( all_results{1,3}.predictions.test,label_test)



else % nesta pipeline tambem se avalia a aplicação da abordagem apenas às samples de test que não tem valores em falta
    
    all_results_with = [];
    all_results_without = [];

    for iter=1:nr_runs

        iter

        % divide data into train and test datasets
        [feat_train, feat_test, label_train, label_test] = division_train_test(features, label);
        
        % impute missing data (if applicable)
        feat_test_original = feat_test;
        [feat_train, feat_test] = impute_missing(modelsToUse, header_modelsToUse, feat_train, feat_test, features_type);
        
        model=1;
        my_model = modelsToUse(1,:);
        
        % normalize data (if applicable)
        [my_feat_train, my_feat_test, norm_mu, norm_sigma] = normalize_data(modelsToUse, header_modelsToUse, feat_train, feat_test, model);

        % balance data (if applicable)
        [my_feat_train, my_label_train, rem_negative_data] = balance_data(modelsToUse, header_modelsToUse, my_feat_train, label_train, model);

        % compute each model(perform_prediction is basically where the
        % magic happens - it is where the most important parts of the
        % methodology are performed)
        
        [~,idx_classificador] = find(strcmpi(header_modelsToUse,'classificador')==1);
        classifier =  my_model(:,idx_classificador);
        my_classifier = classifier{1};
        
        [~,idx_rulesMethod] = find(strcmpi(header_modelsToUse,'tipo de rules')==1);
        rules_type = my_model(:,idx_rulesMethod);
        method_rules = rules_type{1};
        
         [performance_with, performance_without] = ...
             perform_proposedMethodologyMissing(my_feat_train,my_label_train,rem_negative_data,my_feat_test,feat_test_original,label_test,my_classifier, method_rules);
        
         all_results_with = [all_results_with ; performance_with];
            all_results_without = [all_results_without ; performance_without];
        
%         [results] = perform_prediction(my_model, header_modelsToUse, my_feat_train, my_feat_test, feat_test_original,  my_label_train, label_test, rem_negative_data);
%             % save results
%             all_results{iter,model} = results;

    end
    
end


