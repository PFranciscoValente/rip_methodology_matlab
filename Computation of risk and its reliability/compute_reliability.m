%%-----------------------------------------------------------------------
% File to compute the reliability estimation of a single patient
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [reliability_value, mean_neg, mean_pos] = compute_reliability(rules_outputs, rules_acceptance)
    
    % rules that output a negative prediction
    idx_neg = find(rules_outputs == 0);
    neg = rules_acceptance(idx_neg);
    % rules that output a positive prediction
    idx_pos = find(rules_outputs == 1);
    pos = rules_acceptance(idx_pos);

    if length(pos)==0
        pos =0 ;
    elseif length(neg)==0
        neg = 0;
    end

    mean_neg = mean(neg); % media de aceitações para as regras negativas
    mean_pos = mean(pos); % media de aceitações para as regras positivas

    % reliability is the absolute value of the differences between the means
    reliability_value = abs(mean_pos-mean_neg);
    
end