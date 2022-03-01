%%-----------------------------------------------------------------------
% File used to obtain the most common class for a given patient 
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function binary_vector = majority_vote(rules_real_outputs, clf_outputs)

    nr_patients=size(rules_real_outputs,1);
    binary_vector =[];

    for i=1:nr_patients
        used_rules = find(clf_outputs(i,:)==1);
        outputs_used = rules_real_outputs(i,used_rules);
        result = round(mean((outputs_used)));
        binary_vector =[binary_vector ; result ];
    end
end