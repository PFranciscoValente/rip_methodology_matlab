%%-----------------------------------------------------------------------
% File to choose methods to run
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [models, header] = selectMethods

    % escolher quantos métodos se quer experimentar
    % permite experimentar diferentes metodos com o mesmo run
 
    prompt = {'Escolha quantos métodos queres experimentar para cada run:'};
    dlgtitle = 'Número de métodos a utilizar';
    dims = [1 75];
    definput = {'2'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    my_answer1 = str2num(answer{1});
    
    % escolher quais métodos se quer experimentar
    
     models = {};
        
    for i=1:my_answer1
        
        % rules: abordagem baseada em regras (metodologia desenvolvida)
        % standard: abordagem de machine learning tradicional
        
        prompt = {'Classificador - opcoes: nn, lr, svm, et, slr, knn, dt, lda, qda)', ...
            'Escolher abordagem - opcoes: 1) rules, 2) standard'};
        dlgtitle = ['Modelo/classificador ', num2str(i)];
        dims = [1 75];
        definput = {'nn', '1'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        if isequal(answer{2},'1')
            answer{2} = 'rules';
        else
            answer{2} = 'standard';
        end
        
        models{i,1} = answer{1};
        models{i,2} = answer{2};
    
    end
    
    header{1,1} = 'classificador';
    header{1,2} = 'abordagem';
end