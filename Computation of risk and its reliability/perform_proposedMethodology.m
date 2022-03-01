%%-----------------------------------------------------------------------
% File to perform the developed approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [my_predictions, performance, thresholds_rules, threshold_binarization, virtual_negatives_rules, virtual_positives_rules, rules_outputs, rules_geom_means] = perform_proposedMethodology(feat_train,label_train, rem_negative_data, feat_test,label_test,model,method_threshold)
    
    % inputs
    % model = classificador('nn','lr',etc)

    %% CREATE DECISION RULES
    
    % FIND VIRTUAL PATIENTS AND THRESHOLDS FOR RULES 
    % (see function for more details)
        
    feat_train_rules = [feat_train ; rem_negative_data]; % para as regras usa-se tudo
    label_train_rules = [label_train ; zeros(size(rem_negative_data,1),1)];  

    if isequal(method_threshold, 'moving threshold') 
        [rules_outputs, neg_lower_threshold, neg_higher_threshold, d_thresholds_rules, rules_geom_means] = rules_movingThreshold(feat_train_rules,label_train_rules);
    elseif isequal(method_threshold, 'normalized distances') 
        [rules_outputs, virtual_negatives_rules, virtual_positives_rules, d_thresholds_rules, rules_geom_means] = rules_normalizedDistances(feat_train_rules,label_train_rules);
%         [rules_outputs, virtual_negatives_rules, virtual_positives_rules, d_thresholds_rules, rules_geom_means] = rules_normalizedDistances(feat_train_rules,label_train);
    elseif isequal(method_threshold, 'combine rules') 
        [rules_outputs, virtual_negatives_rules, virtual_positives_rules, d_thresholds_rules, rules_geom_means] = rules_normalizedDistancesCombined(my_feat_train_rules,my_label_train);
    elseif isequal(method_threshold, 'tree rules')
        [rules_outputs, ensemble_of_trees, rules_geom_means] = rules_decisionTrees(feat_train_rules,label_train_rules, [], 1, 10, 6, 10, []); 
        virtual_negatives_rules = [];
     virtual_positives_rules = [] ;
    elseif isequal(method_threshold, 'normalized trees')
        [rules_outputs, virtual_negatives_rules, virtual_positives_rules, d_thresholds_rules, rules_geom_means] = rules_normalizedTrees(feat_train_rules,label_train_rules, 50, []);
    elseif isequal(method_threshold, 'two rules')
        [rules_outputs, virtual_negatives_rules, virtual_positives_rules, d_thresholds_rules, rules_geom_means] = rules_twoRules(feat_train_rules,label_train_rules);
    end

    % EVALUATION OF RULES CORRECTENESS IN TRAINING DATASET
    % > for each patient, for each feature, it has a value of 1 if the rule
    % is correct for that patient and a value of 0 if it is wrong
    
    % rules outputs : outputs dados pelas regras 
    % rules acceptance : rule is correct or not for a given patient
    
    rules_outputs = rules_outputs(1:length(label_train),:); % para treinar nao usamos os remaninig negative data
    rules_acceptance = fix(label_train == rules_outputs); 
    
    % APLY THE DECISION RULES TO THE TESTING DATASET 
    % > 'attributed_classes' is the equivalent of 'rules_outputs' but for the testing data 
    
    if isequal(method_threshold, 'moving threshold') 
        attributed_classes = apply_movingThreshold(feat_test, d_thresholds_rules, neg_higher_threshold, neg_lower_threshold);
        rem_classes = apply_movingThreshold(rem_negative_data, d_thresholds_rules, neg_higher_threshold, neg_lower_threshold);
        virtual_negatives_rules = [];
        virtual_positives_rules = [];
    elseif isequal(method_threshold, 'normalized distances') 
        attributed_classes = apply_normalizedDistances(feat_test, virtual_negatives_rules, virtual_positives_rules);
        rem_classes = apply_normalizedDistances(rem_negative_data, virtual_negatives_rules, virtual_positives_rules);
    elseif isequal(method_threshold, 'combine rules') 
        attributed_classes = apply_normalizedDistancesCombined(feat_test, virtual_negatives_rules, virtual_positives_rules);
        rem_classes = apply_normalizedDistancesCombined(rem_negative_data, virtual_negatives_rules, virtual_positives_rules);
    elseif isequal(method_threshold, 'tree rules')
        attributed_classes = apply_treeRules(feat_test, ensemble_of_trees, 1);      
        rem_classes = apply_treeRules(rem_negative_data, ensemble_of_trees, 1);
    elseif isequal(method_threshold, 'normalized trees')
        attributed_classes = apply_normalizedRules(feat_test, virtual_negatives_rules, virtual_positives_rules);
        rem_classes = apply_normalizedRules(rem_negative_data, virtual_negatives_rules, virtual_positives_rules);
    end
    

    % PLOT OF DECISION RULES
    
    if 0 % put "if 1" to show the plots
        if isequal(method_threshold, 'normalized distances') 
            for feat=1:length(d_thresholds_rules)
                visualize_centroids(feat_train_rules(:,feat), label_train, virtual_negatives_rules(:,feat), virtual_positives_rules(:,feat), rules_header(feat));
            end
            pause
            close all
            
        elseif isequal(method_threshold, 'tree rules') 
            visualize_trees(ensemble_of_trees, method_decisionTrees);
            pause
            
        elseif isequal(method_threshold, 'normalized trees')
            for feat=1:size(virtual_negatives_rules,2)
                visualize_treeNormalized(feat, virtual_negatives_rules, virtual_positives_rules, rules_header);
            end
            pause
            close all
        end
    end

    %% THRESHOLDS OF DECISION RULES

    thresholds_rules = [];
    
%     if isequal(method_threshold, 'normalized distances') ||  isequal(method_threshold, 'moving threshold')
%         % denormalization > used if normalization='yes'
%         if isequal(normalization, 'yes')
%             d_thresholds_rules = d_thresholds_rules.*sigma + mu;
%         end
% 
%         thresholds_rules = [thresholds_rules ; d_thresholds_rules];
%     end
%     
    
    %% TRAIN AND TEST
    
    % train and test the classifier
    
    [clf_train_outputs, clf_test_outputs, rem_outputs] = ...
            train_test_classifier(feat_train,feat_test,rules_acceptance, model, 'rules', rem_negative_data);
        
    % TO EVALUATE IF EACH INDIVIDUAL ELEMENT IS CORRECT IN THE TRAINING OF FEATURES:
    % > compare clf_train_outputs with rules_outputs

    
    % EVALUATE PERFORMANCE
    
    % train and test performance metrics
    
%     rem_outputs = 0;
    % performance train (see function for more details)
%     if evolutionary_selection == 0
        [auc_train, optThreshold, spec_train, sens_train, geom_mean_train, train_x, train_y, calibrator, my_fit] = ...
            performance_train(label_train, clf_train_outputs, rules_outputs, 'rules', rem_outputs,rem_classes, model);

        %     else
        % (use of evoluationary algorithm to select features that leads to best performance:)
%         [auc_train, optThreshold, spec_train, sens_train, geom_mean_train, selected_indiv, calibrator] = performance_train_evolucionary(label_train, clf_train_outputs, rules_outputs,  rem_outputs, rem_rules);
%     end
            
  % performance test (see function for more details) 
%     if evolutionary_selection == 0
        [sens_test, spec_test, geom_mean_test, prec_test, f1score_test, conf_matrix_test, auc_test, p_kw_test, rates_reliability, rates_mortality, pos_means, neg_means, reliability, predictions, test_x, test_y, all_calib_rel, all_calib_rates, my_x] = ...
            performance_test(label_test, clf_test_outputs, attributed_classes, 'rules', optThreshold, train_x, train_y, calibrator, my_fit, model);
%     else
%         % (use of evoluationary algorithm to select features that leads to best performance:)        
%         [sens_test, spec_test, geom_mean_test, prec_test, f1score_test, conf_matrix_test, auc_test, p_kw_test,  rates_reliability, rates_mortality, pos_means, neg_means, reliability, predictions] = ...
%             performance_test_evolucionary(label_test, clf_test_outputs, attributed_classes, type_label, optThreshold, selected_indiv, calibrator)
%     end
        
     if 0 % show results in each run (put "if 1" to show)
            
        display(['method: rules'])
        display(['clf: ', model])

%             display ('....train performance.....')
%             display(['     AUC   ','opt threshold   '])
%             display([auc_train, optThreshold])

        display ('....test performance.....')
        display(['     SENS  ','    SPEC   ',' GEOM_MEAN   ', ' AUC   '])
        display([sens_test, spec_test, geom_mean_test, auc_test])
     end       
    
     %% OUTPUTS
     
%      my_predictions.train = clf_train_outputs;
     my_predictions.test = predictions;
     threshold_binarization = optThreshold;
     performance.sens_train = sens_train;
     performance.spec_train = spec_train;
     performance.geom_mean_train = geom_mean_train;
     performance.auc_train = auc_train;
     performance.sens_test = sens_test;
     performance.spec_test = spec_test;
     performance.geom_mean_test = geom_mean_test;
     performance.auc_test = auc_test;
            
end