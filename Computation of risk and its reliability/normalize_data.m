%%-----------------------------------------------------------------------
% File to normalize (zscore) data
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [feat_train, feat_test, mu, sigma] = normalize_data(modelsToUse, header_modelsToUse, feat_train, feat_test, model)

    [~,idx_useNormalization] = find(strcmpi(header_modelsToUse,'normalization')==1);
    normalize = modelsToUse(model,idx_useNormalization);
    
    if isequal(normalize{1},'yes')
        for t=1:size(feat_train,2)
            feat = feat_train(:,t);
            % if it is not binary... (binario nao precisa de normalização)
             if ~all(feat == 1 | feat == 0)
                 [feat_norm,mu,sigma] = zscore(feat);
                 feat_train(:,t) = feat_norm; % normalizaçao treino
                 feat_test(:,t) = (feat_test(:,t) - mu) ./ sigma; % normalizaçao teste
             end       
        end
        
%         % normalization for all variables, including binary ones
%             [feat_train,mu,sigma] = zscore(feat_train);
%             feat_test = (feat_test - mu) ./ sigma;

    else
        mu = []; sigma = [];
    end

end