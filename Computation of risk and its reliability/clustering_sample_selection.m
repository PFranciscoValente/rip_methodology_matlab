%%-----------------------------------------------------------------------
% File to balance the data using the clustering criterion
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function [used_idx0, not_used_idx0, new_features, new_label] = clustering_sample_selection(features, label, ratio)

    %------------------------------------------------------------------------
    % FUNCTION THAT COMPUTES AN UNDERSAMPLING OF THE DATASET USING CLUSTERING
    % It uses a clustering to select the negative samples, so that the selected
    % negative samples are as different from each other as possible (in order
    % to have a more heteregenous group of negative samples).
    %
    % NOTE: the ratio defines the negative-to-positive relationship. If
    % ratio=1, then the number of negative and positive samples will be the
    % same. If ratio=2, the number of negative samples will be the double
    % of positive ones. And so on...
    %------------------------------------------------------------------------

    idx0 = find(label == 0);
    idx1 = find(label == 1);
    tlt0 = label(idx0);
    tlt1 = label(idx1);
    fst0 = features(idx0,:);
    fst1 = features(idx1,:);
    
    my_cluster = linkage(fst0);
    selected = cluster(my_cluster,'maxclust',round(length(fst1)*ratio));
    [~, idx00, ~] = unique(selected);
    tlt0 = tlt0(idx00);
    fst0 = fst0(idx00,:);
    
    new_label = [tlt0 ; tlt1];
    new_features = [fst0 ; fst1];
    
    used_idx0 = idx0(idx00); % amostras negativas utilizadas
    not_used_idx0 = setdiff(idx0,used_idx0); % amostras negativas nao utilizadas
    
    % nota: neste caso estavamos a trabalhar com um dataset que tinhamos
    % mais amostras negativas (classe=0) que positivas (classe=1), por isso 
    % o balanceamento é feito para fazer downsample das amostras negativas
    
end
