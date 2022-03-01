%%-----------------------------------------------------------------------
% File to evaluate training performance, using a evolutionary approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function [auc, optThreshold, spec, sens, geom_mean, selected_indiv, bayesian] = performance_train_evolucionary(true_label, clf_outputs, rules_real_outputs,  rem_outputs, rem_rules)
    
    %% nota
    % Esta função só está preparada para funcionar com classificadores com
    % um output continuo no intevalo [0,1] - NN e LR 
    
    %%% EVOLUCIONARY ALGORITHM 

    num_generations = 4;
    tournament_size = 3;
    population_size = 10;
    cromossome_size = size(clf_outputs,2);
    crossOver_rate = 0.80;
    mutation_rate = 0.15;
    elitism_rate = 0.05;
    
    % população inicial
    population = randi([0 1], population_size, cromossome_size);
    
    rules_out = [rules_real_outputs ; rem_rules];
    rules_prob = [clf_outputs ; rem_outputs];
%     predictions = predict_label(rules_out, rules_prob);
%     predictions2 =  predict_label(rem_rules, rem_outputs);
    new_true = [true_label ; zeros(size(rem_outputs,1),1)];
%     new_predictions = [predictions ; predictions2];
   
    final_fitness = [] ;
    for gen = 1:num_generations
        
        gen
        
        % avaliar individuos da população atual 
       indiv_fitness  = [];
    
%         display(['Generation ', num2str(gen)]);
        
%         evol_rules_real_outputs = rules_real_outputs(:,
%         
        population_size = size(population,1);
        for indiv = 1:population_size
            
%             [gen, indiv]:
            
%             display(['Individuo ', num2str(indiv)]);
%             size(population)
%             indiv
            my_indiv = logical(population(indiv,:));
            my_rules_real_outputs = rules_real_outputs(:,my_indiv);
            my_clf_outputs = clf_outputs(:,my_indiv);
            
%             cv = cvpartition(new_true,'KFold',3,'Stratify',true);
%             
%             runs_indiv_fitness = [];
            
%             for i = 1:cv.NumTestSets
%                 
%                 
%                 
%                 trIdx = cv.training(i);
%                 teIdx = cv.test(i);
%                 
                my_rules_real_outputs = rules_out(:,my_indiv);
                my_clf_outputs = rules_prob(:,my_indiv);
                predictions = predict_label(my_rules_real_outputs, my_clf_outputs);
%                 my_true_label = new_true(teIdx==1);

                %% AUC 
                [X,Y,T,auc,OPTROCPT] = perfcurve(new_true,predictions,1);

            %     % Find the threshold that corresponds to the ROC optimal operating point.
            %     optThreshold= T((X==OPTROCPT(1))&(Y==OPTROCPT(2)));
                % Find the threshold that maximize geometric mean.
                optThreshold = maximize_gm(predictions,new_true);

                % Use the threshold obtained from train.
                binary_predictions = double(predictions>= optThreshold);

                %% STRATIFIED EVALUATION

                TN = length( find(binary_predictions==0 & new_true==0) );
                FN = length( find(binary_predictions==0 & new_true==1) );
                FP = length( find(binary_predictions==1 & new_true==0) );
                TP = length( find(binary_predictions==1 & new_true==1) );

                sens = TP/(TP+FN);
                spec = TN/(TN+FP);
                geom_mean = (sens*spec)^0.5;

%                 runs_indiv_fitness = [runs_indiv_fitness sqrt(auc*geom_mean)];
                
                
%             end
            
            indiv_fitness = [indiv_fitness auc];
            
        end
    
        %%% EVOLUCIONARY ALGORITHM

        nr_parent_survivors = round(elitism_rate*population_size);
        nr_descendents = population_size-nr_parent_survivors;
        
       

        % selecionar progenitores
        mate_pool = [];

        for p=1:nr_descendents

            elems = randperm(population_size,tournament_size);
            indiv1_fit = indiv_fitness(elems(1));
            indiv2_fit = indiv_fitness(elems(2));

            if indiv1_fit>indiv2_fit
                mate_pool = [mate_pool elems(1)];
            else
                mate_pool = [mate_pool elems(2)];
            end
        end

        % variaçoes

        % cross over . progenitores
        pre_descendentes = [];
        for t=1:2:nr_descendents-1
           indiv1_idx = mate_pool(t);
           indiv1 = population(indiv1_idx,:);
           indiv2_idx = mate_pool(t+1);
           indiv2 = population(indiv2_idx,:);
           % one point cross over
           if crossOver_rate > rand(1)
               position = randi(length(indiv1));
               indiv1 = [indiv1(1:position), indiv2(position+1:end)];
               indiv2 = [indiv2(1:position), indiv1(position+1:end)];
           end
           % se a prob random for inferior à rate de crossOVer, entao ficam os
           % individuos iniciais
           pre_descendentes = [pre_descendentes ; indiv1; indiv2];
        end

        % mutation . descendentes
        descendentes = [];
        for n=1:size(pre_descendentes,1)
            new_indiv = pre_descendentes(n,:);
            for g=1:length(new_indiv)
                gene = new_indiv(g);
                if mutation_rate > rand(1)
                   gene(:) = ~gene; % trocar de 0 para 1 ou de 1 para 0.
                end
                % se a prob random for inferior à rate de mutation, entao o
                % gene fica igual
                new_indiv(g)= gene;
            end
            descendentes = [descendentes; new_indiv];
        end

        % elitism
        [values, idx_maxValues] = maxk(indiv_fitness,nr_parent_survivors);
        best_progenitores = population(idx_maxValues,:);

        % nova populaçao
        population = [best_progenitores; descendentes];
        
        final_fitness = indiv_fitness;
    end
    
%     population 
%     final_fitness
    % escolher o melhor individuo
    [~, idx_best] = maxk(final_fitness,1);
    selected_indiv = population(idx_best, :);
    
    new_predictions =  predict_label(rules_out(:,selected_indiv==1), rules_prob(:,selected_indiv==1));
    bayesian = fitglm(new_predictions,new_true,'Distribution','binomial');
    
%     pause
end