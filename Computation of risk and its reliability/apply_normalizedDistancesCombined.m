%------------------------------------------------------------------------
% File to apply to the test set the rules using the normalized distances combined approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [attributed_classes] = apply_normalizedDistancesCombined(feat_test, virtual_negatives, virtual_positives)
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rule
     
    % INPUTS
    % feat_test : NxP matrix of feature values of test dataset

    % OUTPUTS
    % attributed_classes : output given by each rule
    
    %% COMPUTE OUTPUT OF EACH RULE FOR EACH PATIENT

    nr_comb_feat = 2;
    combins = nchoosek([1:size(feat_test,2)],nr_comb_feat);
        
    attributed_classes = [];

    for i=1:size(feat_test,1)

        patient_classes = [];

        for j=1:size(virtual_negatives,2)

            comb = combins(j,:);
            feat_class = 0;

            % compute distance, for each patient, for each feature, to the positive and negative
            % virtual patients. Then compute the normalized distance and find to each class atribute 
            % the sample
            
            all_values = feat_test(:,comb);
            point = all_values(i,:);
            centroid_negative = virtual_negatives(:,j)';
            centroid_positive = virtual_positives(:,j)';

            d_negative = dist(point, centroid_negative, 2);
            d_positive = dist(point, centroid_positive, 2);
            d_normalized1 = 1 - (d_positive./(d_positive+d_negative));

            if d_normalized1>=0.5
                feat_class = 1;
            end

            patient_classes = [patient_classes feat_class];  
        end
        
        attributed_classes = [attributed_classes; patient_classes];
    end
    
end