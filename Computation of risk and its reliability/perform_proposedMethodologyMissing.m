%%-----------------------------------------------------------------------
% File to perform the developed approach (
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [performance_with, performance_without] = perform_proposedMethodologyMissing(feat_train,label_train, rem_negative_data, feat_test, feat_test_original, label_test,model,method_threshold)
    
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
        [rules_outputs, ensemble_of_trees, rules_geom_means] = rules_decisionTrees(feat_train_rules,label_train_rules, [], 1, 20, 6, [], []);   
    elseif isequal(method_threshold, 'normalized trees')
        [rules_outputs, virtual_negatives_rules, virtual_positives_rules, d_thresholds_rules, rules_geom_means] = rules_normalizedTrees(feat_train_rules,label_train_rules, 600, []);
    end

    % EVALUATION OF RULES CORRECTENESS IN TRAINING DATASET
    % > for each patient, for each feature, it has a value of 1 if the rule
    % is correct for that patient and a value of 0 if it is wrong
    
    
    rules_outputs = rules_outputs(1:length(label_train),:); % para treinar nao usamos os remaninig negative data
    rules_acceptance = fix(label_train == rules_outputs);
    
    % APLY THE DECISION RULES TO TESTING DATASET 
    % > 'attributed_classes' is the equivalent of 'rules_outputs' but for the testing data 
    
    % rules outputs : outputs dados pelas regras 
    % rules acceptance : rule is correct or not for a given patient
    
    if isequal(method_threshold, 'moving threshold') 
        attributed_classes = apply_movingThreshold(feat_test, d_thresholds_rules, neg_higher_threshold, neg_lower_threshold);
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
            train_test_classifier(feat_train,feat_test,rules_acceptance, model, 'rules', [], rem_negative_data);
        
    % TO EVALUATE IF EACH INDIVIDUAL ELEMENT IS CORRECT IN THE TRAINING OF FEATURES:
    % > compare clf_train_outputs with rules_outputs
    [auc_train, optThreshold, spec_train, sens_train, geom_mean_train, train_x, train_y, calibrator, my_fit] = ...
                performance_train(label_train, clf_train_outputs, rules_outputs, 'rules', rem_outputs,rem_classes);


        % PREDICTIONS WITH MISSING
        
            % PARA O TEST SO E\\\\\\\0p8/4'p+feat_test_original));
%         feat_test = feat_test(unique(row_missing),:);
        label_aux = label_test(unique(row_missing))';

        clf_test_outputs_with = clf_test_outputs(unique(row_missing),:);
        attributed_classes_with = attributed_classes(unique(row_missing),:);
        
        predictions_with = predict_label(attributed_classes_with, clf_test_outputs_with);
        predictions_with = predict(calibrator,predictions_with)';
  
        % PREDICTIONS WITH NO MISSING
        
        predictions_without = [];
        
        for h=1:length(unique(row_missing))
            
            uniques = unique(row_missing);
            h1 = uniques(h);
            rows = find(row_missing==h1);
            columns = col_missing(rows);
            
            
            clf_test_outputs_withouth = clf_test_outputs(h1,:);
            clf_test_outputs_withouth(columns) = []; 
            attribut    4p0     40ed_classes_without = attr\/)
    '0p     iº7 '   ibuted_classes(h1,:);
            attributed_classes_without(columns) = []; 
            
            predictions_without_aux = predict_label(attributed_classes_without, clf_test_outputs_withouth);
            predictions_without_aux = predict(calibrator,predictions_without_aux);
            predictions_without = [predictions_without predictions_without_aux];
        end
        
        
%         [X,Y,T,auc_with] = perfcurve(label_aux,predictions_with,1);
%         [X,Y,T,auc_without] = perfcurve(label_aux,predictions_without,1);
        
         binary_predictions = double(predictions_with>= optThreshold);
    
        %% STRATIFIED EVALUATION
        
        % TN : true negatives
        % FN : false negatives
        % FP : false positives
        % TP : true positives

        TN_with = length( find(binary_predictions==0 & label_aux==0) )
        FN_with = length( find(binary_predictions==0 & label_aux==1) )
        FP_with = length( find(binary_predictions==1 & label_aux==0) )
        TP_with = length( find(bin                                                                                                                                                                                                          ary_predictions==1 & label_aux==1) )

        performance_with = [TN_with , TP_with, FN_with, FP_with];
%         sens = TP/(TP+FN);
%         spec = TN/(TN+FP);
%         geom_mean_with = (sens*spec)^0.5;
        
        binary_predictions = double(predictions_without>= optThreshold);
    
        %% STRATIFIED EVALUATION

        TN_without = length( find(binary_predictions==0 & label_aux==0) )
        FN_without = length( find(binary_predictions==0 & label_aux==1) )
        FP_without = length( find(binary_predictions==1 & label_aux==0) )
        TP_without = length( find(binary_predictions==1 & label_aux==1) )

        performance_without = [TN_without , TP_without, FN_without, FP_without];

%         sens = TP/(TP+FN);
%         spec = TN/(TN+FP);
%         geom_mean_without = (sens*spec)^0.5;

            
end