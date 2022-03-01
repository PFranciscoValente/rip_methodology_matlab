%%-----------------------------------------------------------------------
% File to get the methods to impute missing values in missing data
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [feat_train, feat_test] = impute_missing(modelsToUse, header_modelsToUse, feat_train, feat_test, features_type)

    [~,idx_useMissing] = find(strcmpi(header_modelsToUse,'use missing')==1);
    use_missing = modelsToUse(1,idx_useMissing);
    [~,idx_useMissingTest] = find(strcmpi(header_modelsToUse,'missing_noUse_inTest')==1);
    use_missing_test = modelsToUse(1,idx_useMissingTest);
    
    if isequal(use_missing{1}, 'yes')
        
        % selected methods to impute missing values for binary, ordinal and
        % continuous variables
        
        [~,idx_binary] = find(strcmpi(header_modelsToUse,'impute binary')==1);
        method_binary = modelsToUse(1,idx_binary);
        [~,idx_ordinal] = find(strcmpi(header_modelsToUse,'impute ordinal')==1);
        method_ordinal = modelsToUse(1,idx_ordinal);
        [~,idx_continuous] = find(strcmpi(header_modelsToUse,'impute continuous')==1);
        method_continuous = modelsToUse(1,idx_continuous);
        
%         if isequal(use_missing_test{1}, 'yes') % neste aqui nao queremos imoputar no test, so treino
%             [feat_train,~] = treat_missing_data(feat_train,feat_test,features_type,method_binary{1}, method_ordinal{1}, method_continuous{1}, 10);
%         else
            [feat_train,feat_test] = treat_missing_data(feat_train,feat_test,features_type,method_binary{1}, method_ordinal{1}, method_continuous{1}, 10);
%         end
    end

end 