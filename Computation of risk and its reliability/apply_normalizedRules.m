%------------------------------------------------------------------------
% File to apply to the test set the rules using the normalized rules approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [attributed_classes] = apply_normalizedRules(feat_test, virtual_negatives, virtual_positives)
   
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rule
     
    % INPUTS
    % feat_test : NxP matrix of feature values of test dataset

    % OUTPUTS
    % attributed_classes : output given by each rule
    
    %% COMPUTE OUTPUT OF EACH RULE FOR EACH PATIENT
    
    attributed_classes = [];
    all_d1 = [];
    all_d2 = [];
    
    for i=1:size(feat_test,1)

        patient_classes = [];
        for feat=1:size(feat_test,2)

            feat_class1 = 0;
            feat_class2 = 0;

            % BRANCH ONE
            
            d_negative1 = dist(feat_test(i,feat), virtual_negatives(1,feat), 2);
            d_positive1 = dist(feat_test(i,feat), virtual_positives(1,feat), 2);
            d_normalized1 = 1 - (d_positive1./(d_positive1+d_negative1));

            if d_normalized1>=0.5
                feat_class1 = 1;
            end
            
            all_d1 = [all_d1 d_normalized1];
%                 
            % BRANCH TWO
            if d_normalized1>=0.5 %entra no branch two positive
                feat_branch2 = virtual_positives(5,feat);
%                 if isnan(feat_branch2)
                if feat_branch2 == feat
                    d_normalized2 = d_normalized1;
                else
                    d_negative2 = dist(feat_test(i,feat_branch2), virtual_negatives(3,feat_branch2), 2);
                    d_positive2 = dist(feat_test(i,feat_branch2), virtual_positives(3,feat_branch2), 2);
                    d_normalized2 = 1 - (d_positive2./(d_positive2+d_negative2));
                end
            else %entra no branch two negative
                feat_branch2 = virtual_negatives(4,feat);
%                 if isnan(feat_branch2) 
                if feat_branch2 == feat
                    d_normalized2 = d_normalized1;
                else
                    d_negative2 = dist(feat_test(i,feat_branch2), virtual_negatives(2,feat_branch2), 2);
                    d_positive2 = dist(feat_test(i,feat_branch2), virtual_positives(2,feat_branch2), 2);
                    d_normalized2 = 1 - (d_positive2./(d_positive2+d_negative2));
                end
            end
% 
            if d_normalized2>=0.5
                feat_class2 = 1;
            end

            all_d2 = [all_d2 d_normalized2];
            
            patient_classes = [patient_classes feat_class2];  
        end
        attributed_classes = [attributed_classes; patient_classes];
    end
    
end