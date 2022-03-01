%------------------------------------------------------------------------
% function to compute the threshold using the normalized trees approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [all_outputs, virtual_negatives, virtual_positives, all_d_thresholds, all_geom_means] = rules_normalizedTrees(features, labels, min_num_samples, header)
    
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
    
    virtual_negatives = [];
    virtual_positives = [];
    all_outputs = [];
    all_outputs_pre = [];
    all_d_thresholds = [];

    %% divide dataset into positive (die) and negative (survived) > FIRST BRANCH
    
    idx_negative = find(labels==0);
    idx_positive = find(labels==1);
    feat_negative = features(idx_negative, :);  % positive data
    feat_positive = features(idx_positive, :); % negative data
        
    negative_nr = length(idx_negative);
    positive_nr = length(idx_positive);
    
    %% create the rule for each feature    
        
    for feat = 1:size(features,2)

        %% FIRST BRANCH (equal to 'normalized distances')
        % COMPUTE THE VIRTUAL PATIENTS - centroids of each class - AND THE NORMALIZED DISTANCE
        
        data = features(:,feat);
        [centroid_negative, centroid_positive, original_threshold, outputs_branch0, geom_mean, ~, ~] = rules_normalized(data, labels);

        %% NEW PROCEEDING : NEW BRANCHES
        
        new_idx_negative = find(outputs_branch0==0);
        new_idx_positive = find(outputs_branch0==1);
        
        % information about samples in negative and positive 'side' of first division
        branch_negative = features(new_idx_negative, :);
        branch_positive = features(new_idx_positive, :);
        branch_negative_label = labels(new_idx_negative);
        branch_positive_label = labels(new_idx_positive);

        % BRANCH POSITIVE (BP)
        bp_idx_negative = find(branch_positive_label==0);
        bp_idx_positive = find(branch_positive_label==1);
        bp_feat_negative = branch_positive(bp_idx_negative, :);
        bp_feat_positive = branch_positive(bp_idx_positive, :);
        
        % BRANCH NEGATIVE (BN)
        bn_idx_negative = find(branch_negative_label==0);
        bn_idx_positive = find(branch_negative_label==1);
        bn_feat_negative = branch_negative(bn_idx_negative, :);
        bn_feat_positive = branch_negative(bn_idx_positive, :);
        
        % COMPUTE NEW DIVISION OF BRANCH NEGATIVE
        % find the discriminant power of the features in the samples of were placed in the negative 'side' of first division
        all_p_values_bn = [];
        for new_feature=1:size(bp_feat_negative,2)
            unique_values = unique(bp_feat_negative(:,new_feature));
            if unique_values<5
                [table,chi2,p_value,table_labels] = crosstab(branch_negative(:,new_feature), branch_negative_label); % create contigency table
            else
                p_value = kruskalwallis(branch_negative(:,new_feature),branch_negative_label,'off');
            end
            all_p_values_bn = [all_p_values_bn p_value];
        end
        
        % COMPUTE NEW DIVISION OF BRANCH POSITIVE
        % find the discriminant power of the features in the samples of were placed in the positive 'side' of first division
        all_p_values_bp = [];
        for new_feature=1:size(bp_feat_positive,2)
            unique_values = unique(bp_feat_positive(:,new_feature));
            if unique_values<5
                [table,chi2,p_value,table_labels] = crosstab(branch_positive(:,new_feature), branch_positive_label); % create contigency table
            else
                p_value = kruskalwallis(branch_positive(:,new_feature),branch_positive_label,'off');
            end
            all_p_values_bp = [all_p_values_bp p_value];
        end
        
        % FIND THE NEW FEATURE TO DIVIDE IN THE BRANCH NEGATIVE (if any)
        num_feat_neg = size(bn_feat_negative,1);
        num_feat_pos = size(bn_feat_positive,1);
        
        if num_feat_neg>=min_num_samples && num_feat_pos>=min_num_samples 
            [p_value,idx_min_neg] = nanmin(all_p_values_bn);
            my_feat = idx_min_neg;
            if p_value<0.01
                bn_feat = my_feat;
            else
                bn_feat = NaN;
            end
        else
            bn_feat = NaN;
        end
           
        % FIND THE NEW FEATURE TO DIVIDE IN THE BRANCH POSITIVE (if any)
        num_feat_neg = size(bp_feat_negative,1);
        num_feat_pos = size(bp_feat_positive,1);
        
        if num_feat_neg>=min_num_samples && num_feat_pos>=min_num_samples 
            [p_value,idx_min_pos] = nanmin(all_p_values_bp);
            my_feat = idx_min_pos;
            if p_value<0.001
                bp_feat = my_feat;
            else
                bp_feat = NaN;
            end
        else
            bp_feat = NaN;
        end
        
        % COMPUTE CENTROIDS AND OUTPUTS OF NEW BRANCHES
        % apply again the normalized distances algorithm
        
%         if ~isnan(bn_feat)
%             
%         end

            if isnan(bn_feat)
                bn_feat = feat;
            end
            
            data = branch_negative(:,bn_feat); 
            
        
            [bn_centroid_negative, bn_centroid_positive, bn_threshold, bn_feat_outputs, ~, ~, ~] = ...
             rules_normalized(data, branch_negative_label);
%             display('::::::::: NEW BRANCH COMPUTED :::::::::::')
%         else
%             bn_centroid_negative = NaN; bn_centroid_positive = NaN;
%             bn_threshold = NaN; bn_feat_outputs = NaN;
%         end
        
%         if ~isnan(bp_feat)
            if isnan(bp_feat)
                bp_feat = feat;
            end
            data = branch_positive(:,bp_feat); 
            
            [bp_centroid_negative, bp_centroid_positive, bp_threshold, bp_feat_outputs, ~, ~, ~] = ...
             rules_normalized(data, branch_positive_label);
%             display('::::::::: NEW BRANCH COMPUTED :::::::::::')
%         else
%             bp_centroid_negative = NaN; bp_centroid_positive = NaN;
%             bp_threshold = NaN; bp_feat_outputs = NaN;
%         end
            
        
        all_geom_means = [];
%         all_d_thresholds = [all_d_thresholds , all_thresholds];
        new_centroid_negative = [centroid_negative; bn_centroid_negative; bp_centroid_negative; bn_feat; bp_feat];
        new_centroid_positive = [centroid_positive; bn_centroid_positive; bp_centroid_positive; bn_feat; bp_feat];
        virtual_negatives = [virtual_negatives , new_centroid_negative];
        virtual_positives = [virtual_positives , new_centroid_positive];

        % output dado por cada regra
        new_feat_outputs = NaN(length(labels),1);
        if bn_feat == feat
            new_feat_outputs(new_idx_negative) = 0;
        else
            new_feat_outputs(new_idx_negative) = bn_feat_outputs;
        end
        if bp_feat == feat
            new_feat_outputs(new_idx_positive) = 1;
        else
            new_feat_outputs(new_idx_positive) = bp_feat_outputs;
        end
        
        all_outputs = [all_outputs, new_feat_outputs];
        all_outputs_pre = [all_outputs_pre, outputs_branch0];
                
    end
    
    mean([virtual_positives(1,:);virtual_negatives(1,:)],1);
    
    %% COMPUTE SOME METRICS ABOUT THE CREATED RULES

    % NEW RULES
    
    all_geom_means = [];
    nr_rules = size(all_outputs,2);
    
    for t=1:nr_rules

        predicted_output = all_outputs(:,t);
        true_negative = length(find(labels(predicted_output==0)==0));
        true_positive = length(find(labels(predicted_output==1)==1));
        % metrics evaluation
        sens = true_negative/negative_nr;
        spec = true_positive/positive_nr;
        geom_mean = sqrt(sens*spec);
        all_geom_means = [all_geom_means , geom_mean];      
    end        
    
    % ONLY BRANCH 0
    
    all_geom_means_pre = [];
    nr_rules = size(all_outputs_pre,2);
    
    for t=1:nr_rules

        predicted_output = all_outputs_pre(:,t);
        true_negative = length(find(labels(predicted_output==0)==0));
        true_positive = length(find(labels(predicted_output==1)==1));
        % metrics evaluation
        sens = true_negative/negative_nr;
        spec = true_positive/positive_nr;
        geom_mean = sqrt(sens*spec);
        all_geom_means_pre = [all_geom_means_pre , geom_mean];      
    end       
    
    % idx onde a media geometrica é melhor
    idx_to_assess = find(all_geom_means_pre > all_geom_means);
%     idx_to_assess = [1 ,2, 3, 4, 6];
    all_geom_means(idx_to_assess) = all_geom_means_pre(idx_to_assess);
%     all_geom_means_pre
    
    for inter = 1:length(idx_to_assess)
        idx = idx_to_assess(inter);
        virtual_negatives(4,idx) = idx;
        virtual_negatives(5,idx) = idx;
        virtual_positives(4,idx) = idx;
        virtual_positives(5,idx) = idx;
    end
%     pause

end