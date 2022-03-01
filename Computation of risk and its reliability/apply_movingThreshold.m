%------------------------------------------------------------------------
% File to apply to the test set the threshold using the moving thereshold approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function [attributed_classes] = apply_movingThreshold(feat_test, d_thresholds, neg_higher_threshold, neg_lower_threshold)
    
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rule
     
    % INPUTS
    % feat_test : NxP matrix of feature values of test dataset

    % OUTPUTS
    % attributed_classes : output given by each rule
    
    %% COMPUTE OUTPUT OF EACH RULE FOR EACH PATIENT
    
    attributed_classes = [];
        
    for i=1:size(feat_test,2)

        feat_threshold = d_thresholds(i);

        if neg_lower_threshold(i)>neg_higher_threshold(i)
            patient_classes = feat_test(:,i) >= feat_threshold;
        else
            patient_classes = feat_test(:,i) <= feat_threshold;
        end
        attributed_classes = [attributed_classes, patient_classes];       
    end
    
end