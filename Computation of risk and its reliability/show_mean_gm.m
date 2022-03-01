%%-----------------------------------------------------------------------
% File to show the geometric mean of the individual rules
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function show_mean_gm(all_results)
    
    for method=1:size(all_results,2)
        
        display(['Method :', num2str(method)])
        
        all_gm_rules = [];

        for run=1:size(all_results,1)
            gm_rules = all_results{run,method};
            all_gm_rules = [all_gm_rules ; gm_rules];
        end

        mean(all_gm_rules)
%         median(all_gm_rules)
        
    end


end