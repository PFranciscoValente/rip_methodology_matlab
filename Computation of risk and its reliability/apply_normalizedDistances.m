%------------------------------------------------------------------------
% File to apply to the test set the rules using the normalized distances approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function [attributed_classes] = apply_normalizedDistances(feat_test, virtual_negatives, virtual_positives)
    

    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rule
     
    % INPUTS
    % feat_test : NxP matrix of feature values of test dataset

    % OUTPUTS
    % attributed_classes : output given by each rule
    
    %% COMPUTE OUTPUT OF EACH RULE FOR EACH PATIENT

    attributed_classes = [];
    all_d = [];

    for i=1:size(feat_test,1)

        patient_classes = [];

        for feat=1:size(feat_test,2)

            feat_class = 0;

            % compute distance, for each patient, for each feature, to the positive and negative
            % virtual patients. Then compute the normalized distance and find to each class atribute 
            % the sample

            d_negative = dist(feat_test(i,feat), virtual_negatives(1,feat), 2);
            d_positive = dist(feat_test(i,feat), virtual_positives(1,feat), 2);
            d_normalized1 = 1 - (d_positive./(d_positive+d_negative));

            if d_normalized1>=0.5
                feat_class = 1;
            end

            patient_classes = [patient_classes feat_class];  
            all_d = [all_d d_normalized1];
        end
        
        attributed_classes = [attributed_classes; patient_classes];
    end
    
end