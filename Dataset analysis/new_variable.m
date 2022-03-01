%------------------------------------------------------------------------
% Auxiliary function to create a new variable from other ones
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function new_var = new_variable(data)

    sumatory_withoutNaN = nansum(data,2)>0;
    sumatory_withNaN = sum(data,2);
    
    new_var = [];
    
    for i=1:length(data)
       
        if sumatory_withoutNaN(i)==1          
            new_var = [new_var ; 1];
            
        elseif isnan(sumatory_withNaN(i))
            new_var = [new_var ; NaN];
            
        else
            new_var= [new_var ; 0];
        
        end
    end
end