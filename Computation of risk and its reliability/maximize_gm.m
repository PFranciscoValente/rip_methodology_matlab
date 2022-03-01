%------------------------------------------------------------------------
% File to find the threshold that maximize the geometric mean of predictions
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function gm_threshold = maximize_gm(predictions,true)
        
    negative_nr = length(find(true==0));
    positive_nr = length(find(true==1));
    
    gm_threshold = 0;
    best_geom_mean = 0;
    
    for d = 0:1/1000:1

        lower_than_threshold = find(predictions<d);
        higher_than_threshold = find(predictions>=d);

        true_negative = length(find(true(lower_than_threshold)==0));
        true_positive = length(find(true(higher_than_threshold)==1));

        % metrics evaluation
        sens = true_negative/negative_nr;
        spec = true_positive/positive_nr;
        geom_mean = sqrt(sens*spec);

        % update the best geometric mean
        if geom_mean>best_geom_mean
            best_geom_mean = geom_mean;
            gm_threshold = d;
        end
    end
    
end