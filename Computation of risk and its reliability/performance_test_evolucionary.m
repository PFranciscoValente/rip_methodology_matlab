%%-----------------------------------------------------------------------
% File to evaluate testing performance, using a evolutionary approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function [sens, spec, geom_mean, prec, f1score, confusion_matrix, auc, p_kw, rates_reliability, rates_mortality, all_pos, all_neg, reliability, predictions] = performance_test_evolucionary(true, clf_outputs, rules_real_outputs, type, optThreshold, selected_indiv, bayesian)
    
    %% nota
    % Esta função só está preparada para funcionar com classificadores com
    % um output continuo no intevalo [0,1] - NN e LR 
    
    %% 
%     [t,i] = max(clf_outputs,[],2);
%     new_clf_outputs = zeros(size(clf_outputs,1),size(clf_outputs,2));
%     for ppp = 1:size(clf_outputs,1)
%         new_clf_outputs(ppp,i(ppp))=1;
%     end
%     clf_outputs = new_clf_outputs;


    selected_indiv = logical(selected_indiv);
    rules_real_outputs = rules_real_outputs(:,selected_indiv);
    clf_outputs = clf_outputs(:,selected_indiv);
    
    if isequal(type,'rules')
        predictions = predict_label(rules_real_outputs, clf_outputs);
        predictions = predict(bayesian,predictions);
    elseif isequal(type,'standard')  
        predictions = clf_outputs;
    end
    
%     predictions
%     pause
    %% AUC e Kruskal-Wallis

    [X,Y,T,auc] = perfcurve(true,predictions,1);
    p_kw = kruskalwallis(predictions,true,'off'); 
    
    % Use the threshold obtained from train.
    binary_predictions = double(predictions>= optThreshold);
    
    %% STRATIFIED EVALUATION
    
    TN = length( find(binary_predictions==0 & true==0) );
    FN = length( find(binary_predictions==0 & true==1) );
    FP = length( find(binary_predictions==1 & true==0) );
    TP = length( find(binary_predictions==1 & true==1) );

    sens = TP/(TP+FN);
    spec = TN/(TN+FP);
    geom_mean = (sens*spec)^0.5;
    
    recall = sens;
    prec = TP/(TP+FP); % precision
    f1score = 2*prec*recall/(prec+recall);

%     true
%     binary_predictions
    confusion_matrix = confusionmat(true, binary_predictions);
    
    %% RISCO VS MORTALITY
    
    if 1
        ranges = [0 0.1 0.2 0.3 0.4 0.5 0.6 1];
        discretization = discretize(predictions,ranges);
        rates = [];
        intervals = unique(discretization);
        sizes = [];
        for bin = 1:length(intervals)
            idx = find(discretization==intervals(bin));
            mortality = true(idx);
            rate = sum(mortality)/length(mortality)*100;
            rates = [rates ; rate];  
            sizes = [sizes ; length(idx)];
        end
        if 0
            figure()
            plot(intervals,rates,'-o')
            % x ticks
            xticks(intervals)
            xticknames = {'[0-10]','[10-20]','[20-30]','[30-40]','[40-50]','[50-100]'};
            xticklabels(xticknames(intervals))
            % text 
            text(intervals,rates+3,num2cell(sizes))
            xlabel ('Risco previsto (%)')
            ylabel ('Taxa de mortalidade (%)')
            ylim([0,100])
            title('Risco de Morte Cardíaca a 6 meses vs Taxa de Mortalidade');
%             pause
        end
    end
    
    rates_mortality = rates';
    if length(rates_mortality)<7
       rates_mortality(7) = NaN; 
    end
    
    if isequal(type,'rules')
        %% RELIABILITY
    
        misclassification = (binary_predictions~=true);

        reliability = [];
        
        all_neg = [];
        all_pos = [];

        for p = 1:size(clf_outputs,1)
            idx_neg = find(rules_real_outputs(p,:)==0);
            size(clf_outputs);
            neg = clf_outputs(p,idx_neg);
            idx_pos = find(rules_real_outputs(p,:)==1);
            pos = clf_outputs(p,idx_pos);

            if length(pos)==0
                pos =0 ;
            elseif length(neg)==0
                neg = 0;
            end
            
%             rules_real_outputs(p,:)
%             clf_outputs(p,:)
            
            all_neg = [all_neg ;mean(neg)];
            all_pos = [all_pos ;mean(pos)];
           
%             true(p)
% 
%             binary_predictions(p)
%             neg
%             pos
%             pause
            
            rel = abs(median(pos)-median(neg)); % median or mean?
            
%             pause
            reliability = [reliability; rel];

        end

        %% RELIABILITY VS MORTALITY 

        stratification_per_mortality=[];

        if 1
            ranges = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 1];
            discretization = discretize(reliability,ranges);
            rates = [];
            intervals = unique(discretization);
            sizes = [];
            for bin = 1:length(intervals)
                idx = find(discretization==intervals(bin));
                %
                mortality = true(idx);
                values = [length(find(mortality==0));length(find(mortality==1))];
                stratification_per_mortality = [stratification_per_mortality , values];
                %
                misc = misclassification(idx);
                rate = sum(misc)/length(misc)*100;
                rates = [rates ; rate];  
                sizes = [sizes ; length(idx)];
            end
            if 0
                figure()
                plot(intervals,rates,'-o')
                % x ticks
                xticks(intervals)
                xticknames = {'[0-50[','[50-60[','[60-70[','[70-80[','[80-90]','[90-100]'};
                xticklabels(xticknames(intervals))
                % text 
                text(intervals,rates+3,num2cell(sizes))
                xlabel ('Reliability')
                ylabel ('Misclassifation (%)')
                title('Reliability vs Misclassifations');
                stratification_per_mortality
                pause
            end
        end

        rates_reliability = rates';
        if length(rates_reliability)<8
           rates_reliability(8) = NaN; 
        end


        %% RELIABILITY VS PREDICTED RISK 

        if 0
            figure()
            plot(predictions*100,reliability*100,'o')
            xlabel ('Predicted Risk (%)')
            ylabel ('Reliability (%)')
            title('Predicted Risk vs Reliability');
            pause
        end
        
    else
        rates_reliability = 0;
        all_pos=0; all_neg=0;
        reliability = 0;
    end
    
    
    
end