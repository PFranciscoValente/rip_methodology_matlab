%------------------------------------------------------------------------
% Function that returns the selected features (their column) giving their names 
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function idx_set = select_features(names_features,header)
   
%     upper_names_features = upper(names_features);
    
    idx_set = [];
    
    for i=1:size(names_features,2)
        
        name = names_features{i};
        [~,idx_feature]= find(strcmpi(header, name));
        idx_set = [idx_set , idx_feature];
        
    end

end