%%-----------------------------------------------------------------------
% File to divide data into training and testing datasets
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [feat_train, feat_test, label_train, label_test] = division_train_test(features, label)

    % codigo comentado: codigo anterior que acho que faz exatamente a mesma
    % coisa que o codigo que nao está comentado e que é mais simples
    
%     sampling_rate = 0.80;
%     positive_label = find(label==1);
%     negative_label = find(label==0);
%     randomized_negative = randperm(length(negative_label));
%     randomized_positive = randperm(length(positive_label));
%     positive_label = positive_label(randomized_positive);
%     negative_label = negative_label(randomized_negative);
%     positive_data_all = features(positive_label,:);
%     negative_data_all = features(negative_label,:);
%     positive_size = round(sampling_rate*length(positive_label));
%     negative_size = round(sampling_rate*length(negative_label));
%     
%     positive_data_train = positive_data_all(1:positive_size,:);
%     negative_data_test = negative_data_all(1:negative_size,:);
%     feat_train = [positive_data_train ; negative_data_test];
%     label_train = [ones(1,positive_size) , zeros(1,negative_size)]';
%     
%     positive_data_test = positive_data_all(positive_size+1:end,:);
%     negative_data_test = negative_data_all(negative_size+1:end,:);
%     feat_test = [positive_data_test ; negative_data_test];
%     label_test = [ones(1,size(positive_data_test,1)) , zeros(1,size(negative_data_test,1))]';


    partition = cvpartition(label,'Holdout',0.20,'Stratify',true);
    idx_train = training(partition);
    idx_test = test(partition);
    
    feat_train = features(idx_train,:);
    feat_test = features(idx_test,:);
    label_train = label(idx_train);
    label_test = label(idx_test);
    
end