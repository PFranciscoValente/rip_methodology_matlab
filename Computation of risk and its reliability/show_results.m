%%-----------------------------------------------------------------------
% File to show the AUC and geometric mean results
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function show_results(all_results)
    
    for method=1:size(all_results,2)
        
        display(['Method :', num2str(method)])
        
        all_auc_test = [];
        all_gm_test = [];

        for run=1:size(all_results,1)
            auc_test = all_results{run,method}.performance.auc_test;
            all_auc_test = [all_auc_test auc_test];
            gm_test = all_results{run,method}.performance.geom_mean_test;
            all_gm_test = [all_gm_test gm_test];
        end

        mean(all_auc_test)
        mean(all_gm_test)
        
    end


end