%%-----------------------------------------------------------------------
% File used to obtain the outcome for each patient considering the rules
% outputs and their predicted acceptances
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%---------------------------------------------------------------------

function prediction = predict_label(rules_output, rules_acceptance)

    nr_patients=size(rules_output,1);
    prediction =[];

    for i=1:nr_patients

       %% Used formulation to compute the prediction
       
        rules_output(rules_output==0) = -1; % convert negative rules to an outpout of -1
        xx = rules_acceptance(i,:).*rules_output(i,:);
        xx(xx==0)= []; % considerar apenas quando a regra é acertada, isto só não acontece se considerarmos aceitações binárias

        if length(xx)==0 % isto só acontece se considerarmos aceitações binárias
            NewValue = 0;
        else
            % OldValue > score in the range [-1,1] 
            OldValue = mean(xx);
            % Normalize the score
            OldMax = 1; OldMin = -1; NewMin = 0; NewMax = 1;
            OldRange = (OldMax - OldMin);  
            NewRange = (NewMax - NewMin);  
            % NewValue > score in the range [0,1] 
            NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;
        end

        prediction = [prediction; NewValue];
        
        %% Auxiliary formulation
        
    %     xx = nn_rules(i,:).*rules_output(i,:);
    %     used_rules = length(find(nn_rules(i,:)==1));
    %     NewValue = sum(xx)/used_rules;

    %     idx1 = find(rules_output(i,:)==1);
    %     idx0 = find(rules_output(i,:)==-1);
    %     
    %     xx0 = mean(nn_rules(i,idx0));
    %     xx1 = mean(nn_rules(i,idx1));
    %     OldValue = (xx1-xx0)/(xx0+xx1);
    %     
    %     OldMax = 1; OldMin = -1; NewMin = 0; NewMax = 1;
    %         OldRange = (OldMax - OldMin);  
    %         NewRange = (NewMax - NewMin);  
    %         NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;
    %     prediction = [prediction; NewValue];        
        
    end
    
end
