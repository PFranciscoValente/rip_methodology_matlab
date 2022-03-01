%%-----------------------------------------------------------------------
% FILE TO COMPUTE THE 95% CONFIDENCE INTERVAL
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------


function ci = confidence_interval(data)

    % Standard Error
    SEM = nanstd(data)/sqrt(length(data)); 
    % T-Score for 95% interval
    ts = tinv([0.025  0.975],length(data)-1)';     
    % Confidence interval 
    ci = nanmean(data) + ts*SEM;                     
%     new_ci = (ci(2)-ci(1))/2; 
    
end
