%%-----------------------------------------------------------------------
% File to select several options like normalization or balancing
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [updated_modelsToUse, updated_header] = selectMoreOptions(modelsToUse, header)

    % ADITIONAL PROCESSING SELECTION
 
    prompt = {'Usar missing data? (yes/no)', 'Testar sem missing?  (yes/no) - se sim, o de cima tem de ser "yes" tambem'};
    dlgtitle = ['Imputação de dados ou não para todos os modelos'];
    dims = [1 100];
    definput = {'yes', 'no'};
    answer_missing = inputdlg(prompt,dlgtitle,dims,definput);

    for t=1:size(modelsToUse,1)
        
        answer_5{t,1} = answer_missing{2};
        
        prompt = {'Normalizacao (yes/no)', 'Balanceamento (yes/no)'};
        dlgtitle = ['Modelo: ',modelsToUse{t,1}, ' ; ', modelsToUse{t,2}, ' ; ' ,modelsToUse{t,3}];
        dims = [1 100];
        definput = {'no', 'yes'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        answer1{t,1} = answer{1};
        
        if isequal(answer{2},'yes')

%             prompt = {'Tipo de balanceamento - 1) simple, 2) clustering', 'Racio de balanceamento - positive-to-negative (ex:1.5)'};
%             dlgtitle = 'Opcoes de balanceamento';
%             dims = [1 100];
%             definput = {'1', '1.5'};
%             answer2 = inputdlg(prompt,dlgtitle,dims,definput);

            answer2{t,1} = 'yes';
            answer2{t,2} = 'simple';
            answer2{t,3} = '1.5';
            
        else
            
            answer2{t,1} = 'no';
            answer2{t,2} = 'NA';
            answer2{t,3} = 'NA';
            
        end
        
        if isequal(answer_missing{1},'yes')

%             prompt = {'Variaveis ordinarias', 'Variaveis binarias', 'Variaveis continuas'};
%             dlgtitle = 'Opcoes de missing imputation';
%             dims = [1 100];
%             definput = {'', '', ''};
%             answer3 = inputdlg(prompt,dlgtitle,dims,definput);

            answer3{t,1} = 'yes'; 
            answer3{t,2} = 'mode knn'; %ordinarias
            answer3{t,3} = 'mode knn'; % binarias
            answer3{t,4} = 'mean knn'; % continuas

        else

            answer3{t,1} = 'no';
            answer3{t,2} = 'NA'; %ordinarias
            answer3{t,3} = 'NA'; % binarias
            answer3{t,4} = 'NA'; % continuas

        end
    
    end
    
    updates = [answer1, answer2, answer3, answer_5];
    updated_modelsToUse = [modelsToUse , updates];
    updated_header = [header , 'normalization', 'balacing', 'balancing type', 'balancing rate', ...
        'use missing', 'impute ordinal', 'impute binary', 'impute continuous', 'missing_noUse_inTest'];
    
end