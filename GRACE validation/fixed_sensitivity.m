%------------------------------------------------------------------------------------
% File used to return the sensitivity value closer to the desired one
% author: Francisco Valente (paulo.francisco.valente@gmail.com), 2021
%------------------------------------------------------------------------------------

function [gm_threshold, sens] = fixed_sensitivity(predictions,true)
        
    negative_nr = length(find(true==0));
    positive_nr = length(find(true==1));
    
    gm_threshold = 0;
    sens_fin = 0;
    
    all_d = [];
    all_sens = [];
    
    for d = 0:1/100:1

        binary_predictions = double(predictions>= d);

        %% STRATIFIED EVALUATION

        TN = length( find(binary_predictions==0 & true==0) );
        FN = length( find(binary_predictions==0 & true==1) );
        FP = length( find(binary_predictions==1 & true==0) );
        TP = length( find(binary_predictions==1 & true==1) );

        sens = TP/(TP+FN);
        spec = TN/(TN+FP);

        all_d = [all_d, d];
        all_sens = [all_sens, sens];
    
%         sens
%         pause
%        
%         if round(sens,2)>=0.77 && round(sens,3)<=0.83
%             sens_fin = sens
%             gm_threshold = d;
% %             break
%         end
        
    end
    
    % Escolher valor desejado de sensitivity
	sensitivity_value = 0.8
	% Obter valor mais próximo
    [val,idx]=min(abs(all_sens-sensitivity_value)); 
    gm_threshold = all_d(idx)
    sens = all_sens(idx)
        
end