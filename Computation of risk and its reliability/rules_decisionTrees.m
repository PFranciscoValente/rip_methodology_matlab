%------------------------------------------------------------------------
% File to compute the threshold using the decision trees approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------


function [all_outputs, ensemble_of_trees, all_geom_means] = rules_decisionTrees(features, labels, feat_header, method, num_trees, num_max_splits, num_min_samples, categorical_vector)
    
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rule
    % M - number of decision_trees (=input num_trees)
    
    
    % INPUTS
    % features : NxP matrix of feature values
    % labels : N-sized vector of true label - death(1) or survival(0)
    % feat_header :  names of the features
    % method : 1 - decision trees (DT) created by a random forest, 2- DT
    % created manually
    % num_trees : number of trees (decision rules) to be created
    % num_max_splits : maximum number of splits for each tree
    % num_min_samples : minimum number of samples in each leaf
    % categorical_vector : N-sized logical vector about the categorical or non-categorical nature of each feature 
     
    % OUTPUTS
    % all_outputs : NxP matrix of outputs given by all the rules 
    % ensemble of trees : group of M small decision trees (rules). if
    % method=1, it is a TreeBagger object, if method=2, it is a Mx2 cell
    % array, where in the first column are the trees and in the second
    % columns the features used in each tree
    % all_geom_mean : P-sized vector of geometric means of all rules
    
    all_geom_means = [];
    virtual_negatives = [];
    virtual_positives = [];
    all_outputs = [];
    all_thresholds = [];

    %% divide dataset into positive (die) and negative (survived)
    
    idx_negative = find(labels==0);
    idx_positive = find(labels==1);
    feat_negative = features(idx_negative, :);  % positive data
    feat_positive = features(idx_positive, :); % negative data
        
    negative_nr = length(idx_negative);
    positive_nr = length(idx_positive);
    
    %% create the rules using a random-forest-based algorithm
    
    if method == 1
        
%                     display('ola1')

        % Create 'random forest' model
        ensemble_of_trees = TreeBagger(num_trees, features, labels, ...
            'PredictorNames', feat_header, 'OOBPrediction', 'on',  ...
            'Method','classification', 'MaxNumSplits', num_max_splits, 'MinLeafSize', num_min_samples,...
            'CategoricalPredictors', categorical_vector);
       
%         t = templateTree('MaxNumSplits', num_max_splits, 'MinLeafSize', num_min_samples,...
%             'CategoricalPredictors', categorical_vector);
%         
%         ensemble_of_trees = fitcensemble(features, labels,'Method','AdaBoostM1','Learners',t,'CrossVal','on');
%         
%             display('ola2')

        % Compute the output given by each rule (tree) for each patient
        all_outputs = [];
        for pat = 1:size(features,1)
            patient_outputs = [];
            for t=1:num_trees % evaluate each tree output
               rule_output = str2num(cell2mat(predict(ensemble_of_trees.Trees{t},features(pat,:)))) ;
               patient_outputs = [patient_outputs , rule_output];
            end
            all_outputs = [all_outputs ; patient_outputs];
        end
    
    %% create the rules computing trees 'manually'

    elseif method == 2
       
       % 'random forest' manually computed:         
       num_samples = round(0.9*length(labels)); % number of samples used in each tree
       num_feat = round(0.75*size(features,2)); % number of features used in each tree
       num_trees = 300; max_feat = 10;
       num_feat = 6;

       ensemble_of_trees = cell(num_trees,2);
       % ensemble of trees is a cell array where the the first column has
       % the decision tree models and the second column has the features
       % used in each one of those threes

       % create the trees
       for t=1:num_trees

           x = randperm(size(features,1),num_samples); % samples used for the tree t
           y = randperm(size(features,2),num_feat); % features used for the tree t
           new_categorical_vector = categorical_vector(y);
           new_data = features(x,y);
           tree = fitctree (new_data, labels(x), 'CategoricalPredictors', new_categorical_vector, 'MaxNumSplits', num_max_splits, 'MinLeafSize', num_min_samples, 'PredictorNames', feat_header(1,y));
               
            ensemble_of_trees{t,1}=tree; 
            ensemble_of_trees{t,2}=y;
            display('ola')
       end
       
       % Compute the output given by each rule (tree) for each patient
        all_outputs = [];
        for pat = 1:size(features,1)
            patient_outputs = [];
            for t=1:num_trees % evaluate each tree output
    %                     view(ensemble{t,1},'Mode','graph') ___> adicionar
               rule_output = predict(ensemble_of_trees{t,1},features(pat,ensemble_of_trees{t,2 })) ;
               patient_outputs = [patient_outputs , rule_output];
            end
            all_outputs = [all_outputs ; patient_outputs];
        end
        
    end
            
    %% COMPUTE SOME METRICS ABOUT THE CREATED RULES

    all_geom_means = [];
    for t=1:num_trees

        predicted_output = all_outputs(:,t);
        true_negative = length(find(labels(predicted_output==0)==0));
        true_positive = length(find(labels(predicted_output==1)==1));
        % metrics evaluation
        sens = true_negative/negative_nr;
        spec = true_positive/positive_nr;
        geom_mean = sqrt(sens*spec);
        all_geom_means = [all_geom_means , geom_mean];      
    end        
end
