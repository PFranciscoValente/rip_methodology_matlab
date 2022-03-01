function [sens, spec, geom_mean, prec, f1score, ppv, npv] = discrimination_metrics(binary_predictions, true)

    TN = length( find(binary_predictions==0 & true==0) ); % true negative
    FN = length( find(binary_predictions==0 & true==1) ); % false negative
    FP = length( find(binary_predictions==1 & true==0) ); % false positive
    TP = length( find(binary_predictions==1 & true==1) ); % true positive

    sens = TP/(TP+FN); % sensitivity
    spec = TN/(TN+FP); % specificity
    geom_mean = (sens*spec)^0.5; % geometric mean of sens and spec
    
    recall = sens;
    prec = TP/(TP+FP); % precision
    f1score = 2*prec*recall/(prec+recall);
    
    ppv = TP/(TP+FP); % negative predictive value
    npv = TN/(TN+FN); % positive predictive value
    
end