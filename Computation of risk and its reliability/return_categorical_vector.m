%------------------------------------------------------------------------
% Function that returns a logical vector informing about the categorical
% nature of the features being used
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [cat_vector, features_type] = return_categorical_vector(features, names_features, feat_header)

    cat_vector = false(1, size(names_features,2));
    features_type = {};
    
    for i=1:size(names_features,2)
        
        name = names_features{i};
        [~,idx_feature]= find(strcmpi(feat_header, name));
        unique_values = unique(features(:,idx_feature));
        unique_values(isnan(unique_values)) = []; % remover nans

        if size(unique_values,1)<5
            cat_vector(i) = true;
            if size(unique_values,1)==2
                features_type = [features_type 'binary']; % binary
            else
                features_type = [features_type 'ordinal']; % ordinal
            end
        else
            features_type = [features_type 'continuous']; % continuous
        end
    end
end