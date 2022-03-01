%%-----------------------------------------------------------------------
% File to perform the standard machine learning approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [my_predictions, performance, threshold_binarization] = perform_standardApproaches(feat_train,label_train,feat_test,label_test,model)
    
    % inputs
    % model = classificador('nn','lr',etc)

    
    %% TRAIN AND TEST
    
    % train and test the classifier
    
    [clf_train_outputs, clf_test_outputs] = ...
                train_test_classifier(feat_train,feat_test, label_train, model, 'standard', []);
            
    % train and test performance metrics
    
    [auc_train, optThreshold, spec_train, sens_train, geom_mean_train, train_x, train_y, ~, ~] = ...
                performance_train(label_train, clf_train_outputs, [], 'standard', [], []);
          
    [sens_test, spec_test, geom_mean_test, prec_test, f1score_test, conf_matrix_test, auc_test, p_kw_test, rates_reliability, rates_mortality, pos_means, neg_means, reliability, predictions, test_x, test_y, calib_rel, calib_rates] = ...
                performance_test(label_test, clf_test_outputs, [], 'standard', optThreshold, train_x, train_y, [], [],model);        
        
     if 0 % put "if 1" to show results in each run; put "if 0" otherwise
            
        display(['method: standard'])
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