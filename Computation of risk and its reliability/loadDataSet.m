%%-----------------------------------------------------------------------
% File to choose the dataset 
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------


function [features, label, my_feat_header, categorical_vector, features_type] = loadDataSet

    prompt = {'Escolha um número (1-lookafterrisk, 2-friend, 3-defaultCreditCard, 4-whiteWineQuality, 5- cervivalCancer, 6-diabetes, 7-heartDisease): '};
    dlgtitle = 'Selecionar dataset';
    dims = [1 75];
    definput = {'1'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);

    my_answer = str2num(answer{1});
    
    if my_answer==1
        display('loading LookAfterRisk dataset...');
        [features, label, my_feat_header, categorical_vector, features_type] = data_lookafterrisk;
    elseif my_answer==2
        display('loading FRIEND dataset...');
        [features, label, my_feat_header, categorical_vector, features_type] = data_friend;
    elseif my_answer==3
        display('loading default credit card dataset...');
        [features, label, my_feat_header, categorical_vector, features_type] = data_defaultCreditCard;
    elseif my_answer==4
        display('loading white wine quality...');
        [features, label, my_feat_header, categorical_vector, features_type] = data_whiteWineQuality;
    elseif my_answer==5
        display('loading cervical cancer...');
        [features, label, my_feat_header, categorical_vector, features_type] = data_cervicalCancer;
    elseif my_answer==6
        display('loading diabetes...');
        [features, label, my_feat_header, categorical_vector, features_type] = data_diabetes;
    elseif my_answer==7
        display('loading heart disease...');
        [features, label, my_feat_header, categorical_vector, features_type] = data_heartDisease;
    end
    
end