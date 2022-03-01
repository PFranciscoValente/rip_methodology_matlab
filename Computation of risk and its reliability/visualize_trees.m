%%-----------------------------------------------------------------------
% File to plot decision trees
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function visualize_trees(ensemble_of_trees, method)
    
    if method==1
        
        for t=1:ensemble_of_trees.NumTrees
            view(ensemble_of_trees.Trees{t},'Mode','graph')
        end
                
    elseif method==2

        for t=1:size(ensemble_of_trees,1)
            view(ensemble_of_trees{t,1},'Mode','graph') 
        end
    end
    
end