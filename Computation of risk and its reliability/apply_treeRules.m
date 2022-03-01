%------------------------------------------------------------------------
% File to apply to the test set the rules using the tree rules approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function [attributed_classes] = apply_treeRules(feat_test, tree_models, method)
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features/variables/rule
     
    % INPUTS
    % feat_test : NxP matrix of feature values of test dataset

    % OUTPUTS
    % attributed_classes : output given by each rule
    
    %% COMPUTE OUTPUT OF EACH RULE FOR EACH PATIENT
    
    attributed_classes = [];
                
    for pat = 1:size(feat_test,1)
        
        patient_outputs = [];
        
        % rules using a random-forest-based algorithm
        
        if method == 1
            
            for t=1:tree_models.NumTrees
                rule_output = str2num(cell2mat(predict(tree_models.Trees{t},feat_test(pat,:)))) ;
                patient_outputs = [patient_outputs , rule_output];
            end  
            
        % rules using a decision trees 'manually' computed
        
        elseif method == 2
            
            for t=1:size(tree_models,1)
                rule_output = predict(tree_models{t,1},feat_test(pat,tree_models{t,2})) ;
                patient_outputs = [patient_outputs , rule_output];
            end
        end

        attributed_classes = [attributed_classes ; patient_outputs];
    end
    
end