%%-----------------------------------------------------------------------
% File used to evaluate the performance in the training dataset
% and also to obtain the calibration model
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [auc, optThreshold, spec, sens, geom_mean, calibrator, ppv, npv] = performance_train(true, rules_acceptance, rules_outputs, type,  rem_rules_acceptance, rem_rules_outputs)
    
    %% nota
    % Esta função só está preparada para funcionar com classificadores com
    % um output continuo no intevalo [0,1] - NN e LR 
   
    % abordagem proposta
    if isequal(type,'rules')
%         clf_outputs = clf_outputs>=0.5; % caso queiramos binarizar
%         rem_outputs = rem_outputs>=0.5;
        % prediction_label > obtain the predictions from the rules outputs and acceptances
        predictions = predict_label(rules_outputs, rules_acceptance);
        predictions2 =  predict_label(rem_rules_outputs, rem_rules_acceptance); % previsoes para os dados que não foram usados no balanceamento
        new_true = [true ; zeros(length(predictions2),1)]; % label do dataset balanceado combinado com label dos dados nao usados no balanceamento
        new_predictions = [predictions ; predictions2]; % previseoes do dataset balanceado combinado com previsoes dos dados nao usados no balanceamento
        
    % abordagem standard machine learning
    elseif isequal(type,'standard')  
        predictions = rules_acceptance;
        new_true = true;
        new_predictions = predictions;
    end

    %% CALIBRATION STEP
    
%     % assessment of calibration quality pre-calibration step
%     nr_tt = 10;
%     quantiles = quantile(new_predictions,0:1/nr_tt:1);
%     x = [];
%     y=[];
%     for tt=1:nr_tt
%         q_idx = find(new_predictions >= quantiles(tt) & new_predictions <= quantiles(tt+1));
%         new_predictions(q_idx)';
%         q_pat = median(new_predictions(q_idx));
%         q_dr = length(find(new_true(q_idx)==1))/length(new_true(q_idx));
%         x = [x q_pat];
%         y = [y q_dr];
%     end
%     train_x = x;
%     train_y = y;
%     figure()
%     plot([0 1],[0 1])
%     hold on 
%     plot(x,y,'-o')
%     calibration curve (my_fit)
%     my_fit = fitlm(x',y','linear');

    % produce calibration model using a logistic regression 
    calibrator = fitglm(new_predictions,new_true,'Distribution','binomial'); 
    estimate = calibrator.Coefficients.Estimate(2);
    pvalue = calibrator.Coefficients.pValue(2);
    calibration = [estimate, pvalue]; % Calibration coefficient and pvalue
    
    
    %% AUC 
    
    predictions_posCalibration =  predict(calibrator,new_predictions);
    [X,Y,T,auc,OPTROCPT] = perfcurve(new_true,predictions_posCalibration,1);
    
    %% STRATIFIED EVALUATION
    
    % a) Define the threshold to categorize the risk into binary groups
    
    % a.1) Find the threshold that corresponds to the ROC optimal operating point.
    % optThreshold= T((X==OPTROCPT(1))&(Y==OPTROCPT(2)));
    
    % a.2) Find the threshold that maximize geometric mean.
    optThreshold = maximize_gm(predictions_posCalibration,new_true);

    % a.3) Find the thresholds closest to a given sensitivity 
    % selec_sens = 0.8182
    % [minValue,closestIndex] = min(abs(Y-selec_sens));
    % optThreshold = T(closestIndex);
    
    % a.4) Fixed threshold
    % optThreshold = 0.0495; % rate of positive events in the dataset
         
    % Binarization
    binary_predictions = double(predictions_posCalibration>= optThreshold);
    
    TN = length( find(binary_predictions==0 & new_true==0) ); %true negative
    FN = length( find(binary_predictions==0 & new_true==1) ); %false negative
    FP = length( find(binary_predictions==1 & new_true==0) ); %false positive
    TP = length( find(binary_predictions==1 & new_true==1) ); %true positive

    sens = TP/(TP+FN); %sensitivity
    spec = TN/(TN+FP); %specificity
    geom_mean = (sens*spec)^0.5; % geometric mean
    
    recall = sens;
    prec = TP/(TP+FP); % precision
    f1score = 2*prec*recall/(prec+recall);
    
    ppv = TP/(TP+FP); % negative predictive value
    npv = TN/(TN+FN); % positive predictive value
      
end