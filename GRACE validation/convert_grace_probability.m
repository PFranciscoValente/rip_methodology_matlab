%------------------------------------------------------------------------------------
% File used to convert the GRACE score to a GRACE risk, i.e., the GRACE probability of
% death in the interval [0,1]
% author: Francisco Valente (paulo.francisco.valente@gmail.com), 2020
%------------------------------------------------------------------------------------

function grace_probability = convert_grace_probability(grace_score, paper)

	%------------------------------------------------------------------------------------
	% note: the reference values were retrieved from the cited papers
	%
	% INPUTS
    % grace_score : number of GRACE points (score) already computed
    % paper : original paper used for computation ('short' > Granger,in-hospital ; 'long' > Fox, 6-months)
	%------------------------------------------------------------------------------------

    grace_probability = 0 ;
    
    % Using the model of in-hospital death - Granger
    % "Predictors of Hospital Mortality in the Global Registry of Acute
    % Coronary Events"
    
    if isequal(paper,'short') 
        
        scores = [0 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250];
        
        probabilities = [0 0.2 0.3 0.4 0.6 0.8 1.1 1.6 2.1 2.9 3.9 5.4 7.3 9.8 13 18 23 29 36 44 52];
        probabilities = probabilities/100;
        
        % interpolate the value based on the discrete values
        grace_probability = interp1(scores,probabilities,grace_score,'linear');
        
        
    % Using the model of 6-months death after admission - Fox
    % "Prediction of risk of death and myocardial infarction in the six
    % months after presentation with acute coronary syndrome:
    % prospective multinational observational study (GRACE)"
    
    elseif isequal(paper,'long') 
        
        scores = [6 27 39 48 55 60 65 69 73 76 88 97 104 110 115 119 123 126 129 132 134 137 139 141 143 ...
            145 147 149 150 152 153 155 156 158 159 160 162 163 174 183 191 200 208 219 285];
        
        probabilities = [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 ...
            20 21 22 23 24 25 26 27 28 29 30 40 50 60 70 80 90 99];
        
        probabilities = probabilities/100;

        % interpolate the value based on the discrete values
        grace_probability = interp1(scores,probabilities,grace_score,'linear');
        
    end
end  