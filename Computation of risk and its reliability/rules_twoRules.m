%------------------------------------------------------------------------
% function to compute the threshold using the two rules approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com
%------------------------------------------------------------------------


function [all_outputs, virtual_negatives, virtual_positives, all_thresholds, all_geom_means] = rules_twoRules(features, labels)
    
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rules
    
    % INPUTS
    % features : NxP matrix of feature values
    % labels : N-sized vector of true label - death(1) or survival(0)
    
    % OUTPUTS
    % all_outputs : NxP matrix of outputs given by all the rules 
    % virtual_negatives : P-sized vector of the negative centroids
    % virtual_positives : P-sized vector of the positive centroids
    % all_thresholds : P-sized vector of the original thresholds (mean of
    % centroids)
    % all_geom_mean : P-sized vector of geometric means of all rules
    
    all_geom_means = [];
    virtual_negatives = [];
    virtual_positives = [];
    all_outputs = [];
    all_thresholds = [];
    
    %% create the rule for each combination of features
        
    % get all the thresholds
    
    for feat = 1:size(features,2)

        %% COMPUTE THE VIRTUAL PATIENTS - centroids of each class - AND THE NORMALIZED DISTANCE
     
        data = features(:,feat);
        [centroid_negative, centroid_positive, original_threshold, feat_outputs, geom_mean, sens, spec] = rules_normalized(data, labels);

        all_thresholds = [all_thresholds , original_threshold];
        virtual_negatives = [virtual_negatives , centroid_negative'];
        virtual_positives = [virtual_positives , centroid_positive'];
        all_outputs = [all_outputs, feat_outputs];
        all_geom_means = [all_geom_means , geom_mean];
          
    end
    
    % get all possible combinations of nr_comb_feat features
    nr_comb_feat = 2;
    combins = nchoosek([1:size(features,2)],nr_comb_feat);
    
    for iter = 1:size(combins,1)
        
        % each combination
        comb = combins(iter,:);
%         data = features(:,comb);
        
        comb1 = comb(1);
        comb2 = comb(2);
        
        output1 = all_outputs(:,comb1);
        output2 = all_outputs(:,comb2);
        
        YY = [output1 output2 output1.*output2  min(1,output1+output2) ];
        
%         possible_outputs = 
        
    end

    
    

end