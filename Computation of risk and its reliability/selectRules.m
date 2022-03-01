%%-----------------------------------------------------------------------
% File to select type of rules
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [updated_modelsToUse, updated_header] = selectRules(modelsToUse, header)

    [i,j] = find(strcmp(modelsToUse, 'rules'));
        
    updated_modelsToUse = modelsToUse; 
    updated_header = header;
    
    for t=1:size(modelsToUse,1)
        
        if ismember(t,i)
        
            % diferentes abordagem experimentadas baseadas em regras
            % a abordagem 1 ('normalized distances') é abordagem que foi seguida 
            % e utilizada nos artigos publicados
            
            prompt = {'Opcoes: 1- normalized distances, 2- tree rules, 3- normalized trees, 4- combine rules, 5- moving threhsold, 6-two rules'};
            dlgtitle = ['Escolher tipo de regras para o modelo ', num2str(t)];
            dims = [1 75];
            definput = {'1'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);


            if isequal(answer{1},'1')
                my_answer = 'normalized distances';
            elseif isequal(answer{1},'2')
                my_answer = 'tree rules';
            elseif isequal(answer{1},'3')
                my_answer = 'normalized trees';
            elseif isequal(answer{1},'4')
                my_answer = 'combine rules';
            elseif isequal(answer{1},'5')
                my_answer = 'moving threshold';
            elseif isequal(answer{1},'6')
                my_answer = 'two rules';
            end

            updated_modelsToUse{t,3} = my_answer;
            
        else
            
            updated_modelsToUse{t,3} = 'NA';
            
        end
    end  
    
    updated_header = [header , 'tipo de rules'];

    
end