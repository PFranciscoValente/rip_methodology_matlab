%%-----------------------------------------------------------------------
% File to remove patients with missing values
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [features, label] = remove_missing(modelsToUse, header_modelsToUse, features, label)

    [~,idx_useMissing] = find(strcmpi(header_modelsToUse,'use missing')==1);
    use_missing = modelsToUse(1,idx_useMissing);
    
    % Choose only patients with no missing values
    if isequal(use_missing{1}, 'no')
        [features, idx_toRemove] = rmmissing(features);
        label(idx_toRemove==1) = []; 
    end

end