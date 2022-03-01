%%-----------------------------------------------------------------------
% File used to evaluate the performance in the testing dataset
% and also to obtain the reliability estimations, the rate of missclassifications 
% based on the reliability, and the calibration assessment
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [sens, spec, geom_mean, prec, f1score, ppv, npv, confusion_matrix, auc, p_kw, reliability_values, rates_reliability, all_pos, all_neg, predictions, predicted_events, observed_events, nrInstances_quantile_reliab] = performance_test(true, rules_acceptance, rules_outputs, type, optThreshold, calibrator)
    
    %% nota
    % Esta função só está preparada para funcionar com classificadores com
    % um output continuo no intevalo [0,1] - NN e LR 
    
    % abordagem proposta
    if isequal(type,'rules')
%         clf_outputs = clf_outputs>=0.5; % caso queiramos binarizar
        predictions = predict_label(rules_outputs, rules_acceptance);
        predictions = predict(calibrator,predictions); % calibrate the predictions
        
    % abordagem standard machine learning    
    elseif isequal(type,'standard')  
        predictions = rules_acceptance;
    end

    %% AUC e Kruskal-Wallis

    [X,Y,T,auc] = perfcurve(true,predictions,1);
    p_kw = kruskalwallis(predictions,true,'off'); % p_value kruskal wallis
    
    %% STRATIFIED EVALUATION
    
    % a) Define the threshold to categorize the risk into binary groups
    
    % a.1) Threshold obtained in the training dataset (given as input to the function)
    optThreshold = optThreshold;
   
    % a.2) Find the thresholds closest to a given sensitivity 
    % selec_sens = 0.8
    % [minValue,closestIndex] = min(abs(Y-selec_sens));
    % optThreshold = T(closestIndex);
    
    % a.3) Fixed threshold
    % optThreshold = 0.0495; % rate of positive events in the dataset
    
    % Binarization
    binary_predictions = double(predictions>= optThreshold);

    TN = length( find(binary_predictions==0 & true==0) );  %true negative
    FN = length( find(binary_predictions==0 & true==1) ); %false negative
    FP = length( find(binary_predictions==1 & true==0) ); %false positive
    TP = length( find(binary_predictions==1 & true==1) ); %true positive

    sens = TP/(TP+FN); %sensitivity
    spec = TN/(TN+FP); %specificity
    geom_mean = (sens*spec)^0.5; % geometric mean
    
    recall = sens;
    prec = TP/(TP+FP); % precision
    f1score = 2*prec*recall/(prec+recall);
    
    ppv = TP/(TP+FP); % negative predictive value
    npv = TN/(TN+FN); % positive predictive value

    confusion_matrix = confusionmat(true, binary_predictions);
    
    % Most common class outputed by the rules for a given patient
    % only available if the output of the rules is binary
    % majority = majority_vote(rules_real_outputs, clf_outputs);
    
    %% CALIBRATION VALUES (PREDICTED RISK VS OBSERVED ONE)

    nr_quantiles = 10;
    quantiles = quantile(predictions,0:1/nr_quantiles:1);
    
    predicted_events = [];
    observed_events = [];
    
    for iter_quantile=1:nr_quantiles
        
        quantile_idx = find(predictions >= quantiles(iter_quantile) & predictions <= quantiles(iter_quantile+1)); % idx de pacientes com risk incluido no quantile atual
        quantile_mean_risk = mean(predictions(quantile_idx)); % risco predito médio (predicted mortality) dos pacientes incluidos no quantile
        quantile_observed_events = length(find(true(quantile_idx)==1))/length(true(quantile_idx)); % taxa de eventos positivos (observed mortality) dos pacientes incluidos no quantile
        
        predicted_events = [predicted_events, quantile_mean_risk];
        observed_events = [observed_events, quantile_observed_events];
        
    end
    
    if 0 % plot de predicted vs observed events para este run
        figure()
        plot(predicted_events,observed_events,'-o')
        xlabel ('Predicted mortality (%)')
        ylabel ('Observed mortality (%)')
        title('Predicted mortality vs Observed mortality');
        ylim([0 50])
        pause
    end
    
    if isequal(type,'rules')
        
        %% RELIABILITY ESTIMATIONS
   
        reliability_values = [];
        all_neg = [];
        all_pos = [];

        for p = 1:size(rules_acceptance,1)
            
            % function to compute the individual reliability estimation
            [reliab_value, mean_neg, mean_pos] = compute_reliability(rules_outputs(p,:), rules_acceptance(p,:));
            
            reliability_values = [reliability_values; reliab_value];

            all_neg = [all_neg ; mean_neg];
            all_pos = [all_pos ; mean_pos];
           
        end
        
        
        %% RELIABILITY VS MORTALITY 

        misclassification = (binary_predictions~=true);
        
        if 1
            
            % dicretização dos valores de reliability em intervalos de 10%
            ranges = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            intervals = 1:10;
            discretization = discretize(reliability_values,ranges);
            
            rates_reliability = []; % taxas de reliability para todos os intervalos
            nrInstances_quantile_reliab = []; % numero de pacientes incluidos nos intervalos
            
            for bin = 1:length(intervals)
                
                idx = find(discretization==intervals(bin)); % idx de individuals com reliability no intervalo bin
                nrInstances_quantile_reliab = [nrInstances_quantile_reliab, length(idx)]; % numero de pacientes incluidos neste intervalo
                % c
                mortality = true(idx); % true label
                
                % values =
                % [length(find(mortality==0));length(find(mortality==1))];
                % % 
 
                % CALCULAR RATE OF MISCLASSIFICATIONS (rates) 
                misc = misclassification(idx); % verify misclissification in the individuals in the current interval
                if isempty(idx)
                    rates_reliability = [rates_reliability, NaN];  
                else
                    rate = sum(misc)/length(misc)*100;
                    rates_reliability = [rates_reliability, rate];  
                end
                
            end
            
            if 0 % plot de reliability vs misclassification para este run
                figure()
                plot(intervals,rates_reliability,'-o')
                xticks(intervals)
                xticknames = {'[0-10[','[10-20[','[20-30[','[30-40[','[40-50]','[50-60]','[60-70]','[70-80]','[80-90]','[90-100]'};
                xticklabels(xticknames(intervals))
                text(intervals,rates+3,num2cell(nrInstances_quantile_reliab))
                xlabel ('Reliability')
                ylabel ('Misclassifation (%)')
                title('Reliability vs Misclassifations');
                ylim([0 50])
                pause
            end
            
        end  

        %% RELIABILITY VS PREDICTED RISK 

        if 0
            figure()
            plot(predictions*100,reliability_values*100,'o')
            xlabel ('Predicted Risk (%)')
            ylabel ('Reliability (%)')
            title('Predicted Risk vs Reliability');
            pause
        end

        
    else
        
        % para standard machine learning estes valores não são obtidos
        all_pos = []; all_neg = [];
        reliability_values = [];
        rates_reliability = [];
        nrInstances_quantile_reliab = [];
                         
    end
    
end