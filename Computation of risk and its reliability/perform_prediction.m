%%-----------------------------------------------------------------------
% File to perform the most important parts of the methodology
% (rules creation, prediction models creation, risk computation)
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------


function [results,virtual_negatives_rules, virtual_positives_rules, rules_geom_means, attributed_classes] = perform_prediction(model, header_modelsToUse, feat_train, feat_test, label_train, label_test, rem_negative_data)

    % get classification models to use
    [~,idx_abordagem] = find(strcmpi(header_modelsToUse,'abordagem')==1);
    approach = model(:,idx_abordagem);
    [~,idx_classificador] = find(strcmpi(header_modelsToUse,'classificador')==1);
    classifier =  model(:,idx_classificador);
    my_classifier = classifier{1};
    
    
    % Proposed methdology based on a decision set of rules and the
    % computation of their likelihood of being correct
    
    if isequal(approach{1}, 'rules')
        
        % get rules type to use
        [~,idx_rulesMethod] = find(strcmpi(header_modelsToUse,'tipo de rules')==1);
        rules_type = model(:,idx_rulesMethod);
        method_rules = rules_type{1};

        [~,idx_useMissingTest] = find(strcmpi(header_modelsToUse,'missing_noUse_inTest')==1);
        use_missing_test = model(:,idx_useMissingTest);
        
        if isequal(use_missing_test{1}, 'yes') %missing analysis
            [predictions, performance, thresholds_rules, threshold_binarization, virtual_negatives_rules, virtual_positives_rules] = ...
            perform_proposedMethodologyMissing(feat_train,label_train,rem_negative_data,feat_test,label_test,my_classifier, method_rules);
            rules_geom_means = [];
        else
            [predictions, performance, thresholds_rules, threshold_binarization, virtual_negatives_rules, virtual_positives_rules, attributed_classes, rules_geom_means] = ...
            perform_proposedMethodology(feat_train,label_train,rem_negative_data,feat_test,label_test,my_classifier, method_rules);
        end
    
        
    % Methodology considering a traditional machine learning approach
    % (mainly for comparison purposes)
    
    elseif isequal(approach{1}, 'standard')
        [predictions, performance, threshold_binarization] = ...
            perform_standardApproaches(feat_train,label_train,feat_test,label_test,my_classifier);
        virtual_negatives_rules = 0; virtual_positives_rules = 0; % these 2 vectors are not used 
        rules_geom_means = []; attributed_classes = []; % these 2 vectors are not used
    end

    % output the results
    results.predictions = predictions;
    results.performance = performance;
    results.threshold_binarization = threshold_binarization;
end 