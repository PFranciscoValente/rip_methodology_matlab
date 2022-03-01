%------------------------------------------------------------------------
% File to compute the threshold using the moving threshold approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com
% 2020
%------------------------------------------------------------------------

function [all_outputs, neg_lower_threshold, neg_higher_threshold, all_thresholds, all_geom_means] = rules_movingThreshold(features, labels)
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rules
    
    % INPUTS
    % features : NxP matrix of feature values
    % labels : N-sized vector of true label - death(1) or survival(0)
    
    % OUTPUTS
    % all_outputs : NxP matrix of outputs given by all the rules 
    % all_thresholds : P-sized vector of the thresholds
    % all_geom_mean : P-sized vector of geometric means of all rules
    % neg_lower_threshold, neg_higher_threshold > VER O QUE SAO
    
    all_geom_means = [];
    all_thresholds =[];
    all_outputs = [];
    neg_lower_threshold = [];
    neg_higher_threshold = [];

    %% compute number of positive (die) and negative (survived)
    
    idx_negative = find(labels==0);
    idx_positive = find(labels==1);
    negative_nr = length(idx_negative);
    positive_nr = length(idx_positive);
    
    %% create the rule for each feature    
        
    for feat = 1:size(features,2)

        min_value = min(features(:,feat));
        max_value = max(features(:,feat));
        best_geom_mean = 0;
        lower_threshold = [];
        higher_threshold = [];

        for d = min_value:(max_value-min_value)/1000:max_value

            lower_than_threshold = find(features(:,feat)<d);
            higher_than_threshold = find(features(:,feat)>=d);

            idx_neg_lt = length(find(labels(lower_than_threshold)==0));
            idx_pos_lt = length(find(labels(lower_than_threshold)==1));
            neg_lt = idx_neg_lt/(idx_neg_lt+idx_pos_lt);
            idx_neg_ht = length(find(labels(higher_than_threshold)==0));
            idx_pos_ht = length(find(labels(higher_than_threshold)==1));
            neg_ht = idx_neg_ht/(idx_neg_ht+idx_pos_ht);

            if neg_lt>neg_ht
                true_negative = length(find(labels(lower_than_threshold)==0));
                true_positive = length(find(labels(higher_than_threshold)==1));
            else
                true_negative = length(find(labels(higher_than_threshold)==0));
                true_positive = length(find(labels(lower_than_threshold)==1));
            end

            % metrics evaluation
            if neg_ht>0 && neg_lt>0
                sens = true_negative/negative_nr;
                spec = true_positive/positive_nr;
                geom_mean = sqrt(sens*spec);
                % geom_mean = sens + spec -1; % youden's index
            else
                geom_mean = 0;
            end

            if geom_mean>best_geom_mean

                best_geom_mean = geom_mean;
                best_threshold = d;
                lower_threshold = neg_lt;
                higher_threshold = neg_ht;
            end
        end

        % Compute the output given by the rule for each patient   
        feat_outputs = features(:,feat) >= best_threshold;
        
        all_geom_means = [all_geom_means , best_geom_mean];
        all_thresholds =[all_thresholds , best_threshold];
        all_outputs = [all_outputs, feat_outputs];
        neg_lower_threshold = [neg_lower_threshold lower_threshold];
        neg_higher_threshold = [neg_higher_threshold higher_threshold];

    end

end