%%-----------------------------------------------------------------------
% File to balance the data
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [feat_train, label_train, rem_negative_data] = balance_data(modelsToUse, header_modelsToUse, feat_train, label_train, model)

    [~,idx_balance] = find(strcmpi(header_modelsToUse,'balacing')==1);
    balance = modelsToUse(model,idx_balance);
    
    if isequal(balance{1},'yes')
        
        [~,idx_balanceType] = find(strcmpi(header_modelsToUse,'balancing type')==1);
        balance_type = modelsToUse(model,idx_balanceType);
        
        [~,idx_balanceRate] = find(strcmpi(header_modelsToUse,'balancing rate')==1);
        balance_rate = modelsToUse(model,idx_balanceRate);
        ratio_balancing = str2num(balance_rate{1});
        
        idx_positive = find(label_train==1);
        idx_negative = find(label_train==0);
        positive_size = length(idx_positive);
            
        positive_data = feat_train(idx_positive,:);
        negative_data = feat_train(idx_negative,:);
        select_negativeSize = round(ratio_balancing*positive_size);
        
        % simple balancing: 
        % random samples are chosen
        
        if isequal(balance_type{1}, 'simple')

            my_negative_data = negative_data(1:select_negativeSize,:);
            rem_negative_data = negative_data(select_negativeSize+1:end,:);
            feat_train = [positive_data ; my_negative_data];
            label_train = [ones(1,positive_size) , zeros(1,select_negativeSize)]';

        % clustering balancing:
        % it is performed a clustering of data to downsample, and then it
        % is chosen a point of each cluster (see
        % clustering_sample_selection function for further information)
        
        elseif isequal(balance_type{1}, 'clustering')
            
            [used_idx0, not_used_idx0, feat_train, label_train] = clustering_sample_selection(feat_train, label_train, ratio_balancing);
            used_idx = [[1:positive_size]' ; used_idx0];
            rem_negative_data = feat_train(not_used_idx0,:);        
        end
        
    else
        rem_negative_data = []; % nao se aplica quando nao ha balanceamento
    end

end