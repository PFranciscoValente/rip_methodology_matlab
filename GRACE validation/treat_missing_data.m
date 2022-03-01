%%-----------------------------------------------------------------------
% File to impute missing values in missing data
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function [new_feat_train,new_feat_test] = treat_missing_data(feat_train,feat_test,features_type,method_binary, method_ordinal, method_continuous, knn_value)

    %------------------------------------------------------------------------------------
    % FUNCTION TO INPUTE MISSING VALUES
    %
    % The available method for imputation are:
    %
    % > for continous variables
    % 'mean all' : the missing value is replaced by the mean of all non-missing values of its feature
    % 'mean knn' : the missing value is replaced by the mean of the knn non-missing values of its feature
    %
    % > for categotical and binary variables
    % 'lower': the missing value is replaced by the lowest value of its feature, which is 
    % 0 for binary variables and 1 for ordinal ones) >> it represents no condition / no medication
    % 'mode all' : the missing value is replaced by the mode of all non-missing values of its feature
    % 'mode knn' : the missing value is replaced by the mode of the knn non-missing values of its feature
    %
    %------------------------------------------------------------------------
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features
    
    % INPUTS
    % feat_train : NxP matrix of training feature values before missing imputation
    % feat_test : NxP matrix of testing feature values before missing imputation
    % headers : features name
    % method_binary : method used for imputation in binary variables
    % method_ordinal : method used for imputation in ordinal variables
    % method_continuous : method used for imputation in continuous variables
    % knn_value : number of neighbours chosed in knn algorithm > used for 'mean knn' and 'mode knn'    
    
    % OUTPUTS
    % new_feat_train : NxP matrix of training feature values after missing imputation
    % new_feat_test : NxP matrix of testing feature values after missing imputation
    
    %%  
    new_feat_train = feat_train;
    new_feat_test = feat_test;
   
    %% TRAIN
    
    % find all the missing values
    [row,col] = find(ismissing(feat_train)==1);

    for i=1:length(row)
        
        idx_col = col(i); % obtain index of column with the missing value
        type = features_type{idx_col};
        
        % CATEGORICAL VARIABLES
        
        if isequal(type, 'binary')

            if isequal(method_binary, 'lower')
                new_feat_train(row(i),col(i)) = min(feat_train(:,col(i)));
                
            elseif isequal(method_binary, 'mode all')
                new_feat_train(row(i),col(i)) = mode(feat_train(:,col(i)));
                
            elseif isequal(method_binary, 'mode knn')
                
                feat_train_aux = feat_train;
                feat_to_input = feat_train_aux(:, col(i));
                feat_train_aux(:,col(i)) = []; 
                feat_train_missing = feat_train_aux(row(i),:);
                feat_train_aux(row(i),:) = [];
                feat_to_input(row(i)) = [];
                % it is only consider non-missing values
                [feat_train_aux, idx_toRemove] = rmmissing(feat_train_aux);
                feat_to_input(idx_toRemove) = [];
                [feat_train_missing, idx_toRemove] = rmmissing(feat_train_missing,2);
                feat_train_aux(:,idx_toRemove) = [];
                [feat_to_input, idx_toRemove] = rmmissing(feat_to_input);
                feat_train_aux(idx_toRemove,:) = [];
                % compute the mode of the knn values
                idx_to_input = knnsearch(feat_train_aux,feat_train_missing,'K',knn_value);
                mode_of_knn = mode(feat_to_input(idx_to_input));
                new_feat_train(row(i),col(i)) = mode_of_knn;
            end
            
        % ORDINAL VARIABLES
        
        elseif isequal(type, 'ordinal')

            if isequal(method_ordinal, 'lower')
                new_feat_train(row(i),col(i)) = min(feat_train(:,col(i)));
                
            elseif isequal(method_ordinal, 'mode all')
                new_feat_train(row(i),col(i)) = mode(feat_train(:,col(i)));
                
            elseif isequal(method_ordinal, 'mode knn')

                feat_train_aux = feat_train;
                feat_to_input = feat_train_aux(:, col(i));
                feat_train_aux(:,col(i)) = []; 
                feat_train_missing = feat_train_aux(row(i),:);
                feat_train_aux(row(i),:) = [];
                feat_to_input(row(i)) = [];
                % it is only consider non-missing values
                [feat_train_aux, idx_toRemove] = rmmissing(feat_train_aux);
                feat_to_input(idx_toRemove) = [];
                [feat_train_missing, idx_toRemove] = rmmissing(feat_train_missing,2);
                feat_train_aux(:,idx_toRemove) = [];
                [feat_to_input, idx_toRemove] = rmmissing(feat_to_input);
                feat_train_aux(idx_toRemove,:) = [];
                % compute the mode of the knn values
                idx_to_input = knnsearch(feat_train_aux,feat_train_missing,'K',knn_value);
                mode_of_knn = mode(feat_to_input(idx_to_input));
                new_feat_train(row(i),col(i)) = mode_of_knn;
            end
            
        % CONTINUOUS VARIABLES
        
        else
            if isequal(method_continuous, 'mean all')
                new_feat_train(row(i),col(i)) = nanmean(feat_train(:,col(i)));
                
            elseif isequal(method_continuous, 'mean knn')

                feat_train_aux = feat_train;
                feat_to_input = feat_train_aux(:, col(i));
                feat_train_aux(:,col(i)) = []; 
                feat_train_missing = feat_train_aux(row(i),:);
                feat_train_aux(row(i),:) = [];
                feat_to_input(row(i)) = [];
                % it is only consider non-missing values
                [feat_train_aux, idx_toRemove] = rmmissing(feat_train_aux);
                feat_to_input(idx_toRemove) = [];
                [feat_train_missing, idx_toRemove] = rmmissing(feat_train_missing,2);
                feat_train_aux(:,idx_toRemove) = [];
                [feat_to_input, idx_toRemove] = rmmissing(feat_to_input);
                feat_train_aux(idx_toRemove,:) = [];
                % compute the mean of the knn values
                idx_to_input = knnsearch(feat_train_aux,feat_train_missing,'K',knn_value);
                mean_of_knn = mean(feat_to_input(idx_to_input));
                new_feat_train(row(i),col(i)) = mean_of_knn;
            end
        end
    end
  
    %% TEST > repeat process, based on train values
    
    % find all the missing values
    [row,col] = find(ismissing(feat_test)==1);

    for i=1:length(row)
        
        idx_col = col(i); % ver qual o idx da coluna com o valor em falta
        type = features_type{idx_col};
       
        % CATEGORICAL VARIABLES
        
        if isequal(type, 'binary')

            if isequal(method_binary, 'lower')
                new_feat_train(row(i),col(i)) = min(feat_train(:,col(i)));
                
            elseif isequal(method_binary, 'mode all')
                new_feat_train(row(i),col(i)) = mode(feat_train(:,col(i)));
                
            elseif isequal(method_binary, 'mode knn')

                feat_train_aux = feat_train;
                feat_to_input = feat_train_aux(:, col(i));
                feat_train_aux(:,col(i)) = []; 
                feat_test_missing = feat_test(row(i),:);
                feat_test_missing(:,col(i)) = [];

                [feat_train_aux, idx_toRemove] = rmmissing(feat_train_aux);
                feat_to_input(idx_toRemove) = [];
                [feat_test_missing, idx_toRemove] = rmmissing(feat_test_missing,2);
                feat_train_aux(:,idx_toRemove) = [];
                [feat_to_input, idx_toRemove] = rmmissing(feat_to_input);
                feat_train_aux(idx_toRemove,:) = [];

                idx_to_input = knnsearch(feat_train_aux,feat_test_missing,'K',knn_value);
                mode_of_knn = mode(feat_to_input(idx_to_input));
                new_feat_test(row(i),col(i)) = mode_of_knn;
            end
        
        % ORDINAL VARIABLES    
        
        elseif isequal(type, 'ordinal')

            if isequal(method_ordinal, 'lower')
                new_feat_train(row(i),col(i)) = min(feat_train(:,col(i)));
                
            elseif isequal(method_ordinal, 'mode all')
                new_feat_train(row(i),col(i)) = mode(feat_train(:,col(i)));
                
            elseif isequal(method_ordinal, 'mode knn')

                feat_train_aux = feat_train;
                feat_to_input = feat_train_aux(:, col(i));
                feat_train_aux(:,col(i)) = []; 
                feat_test_missing = feat_test(row(i),:);
                feat_test_missing(:,col(i)) = [];

                [feat_train_aux, idx_toRemove] = rmmissing(feat_train_aux);
                feat_to_input(idx_toRemove) = [];
                [feat_test_missing, idx_toRemove] = rmmissing(feat_test_missing,2);
                feat_train_aux(:,idx_toRemove) = [];
                [feat_to_input, idx_toRemove] = rmmissing(feat_to_input);
                feat_train_aux(idx_toRemove,:) = [];

                idx_to_input = knnsearch(feat_train_aux,feat_test_missing,'K',knn_value);
                mode_of_knn = mode(feat_to_input(idx_to_input));
                new_feat_test(row(i),col(i)) = mode_of_knn;
            end
            
        % CONTINUOUS VARIABLES
        
        else
            if isequal(method_continuous, 'mean all')
                new_feat_test(row(i),col(i)) = nanmean(feat_train(:,col(i)));
                
            elseif isequal(method_continuous, 'mean knn')

                feat_train_aux = feat_train;
                feat_to_input = feat_train_aux(:, col(i));
                feat_train_aux(:,col(i)) = []; 
                feat_test_missing = feat_test(row(i),:);
                feat_test_missing(:,col(i)) = [];

                [feat_train_aux, idx_toRemove] = rmmissing(feat_train_aux);
                feat_to_input(idx_toRemove) = [];
                [feat_test_missing, idx_toRemove] = rmmissing(feat_test_missing,2);
                feat_train_aux(:,idx_toRemove) = [];
                [feat_to_input, idx_toRemove] = rmmissing(feat_to_input);
                feat_train_aux(idx_toRemove,:) = [];

                idx_to_input = knnsearch(feat_train_aux,feat_test_missing,'K',knn_value);
                mean_of_knn = mean(feat_to_input(idx_to_input));
                new_feat_test(row(i),col(i)) = mean_of_knn;
            end
        end
    end
    
end