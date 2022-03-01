%%-----------------------------------------------------------------------
% File used to stratify the GRACE risk into low or high groups and get 
% discrimination metrics
% author: Francisco Valente (paulo.francisco.valente@gmail.com), 2020
%------------------------------------------------------------------------

function [geom_mean, sens, spec, f1score, npv, ppv] = stratify_grace(grace_risk, true, paper, type, diagnostico, separation)

    %------------------------------------------------------------------------
    % note1: the reference values were retrieved from the cited papers
    % note2: those values depends on the diagnostic (ua, nstemi or stemi)
    %------------------------------------------------------------------------
    
    %% PARAMETERS 
   
    % INPUTS
    % grace_risk : grace score or probability already computed
    % true : true label of each patient
    % paper : original paper used for computation ('short' > Granger,in-hospital ; 'long' > Fox, 6-months)
    % type : type of grace output (score or probability)
    % diagnostico : diagnostic value of each patient
    % separation : type of GRACE rearrange into only two categories (low and high risk)
    
    % OUTPUTS
    % geom_mean: geometric mean
    % sens : sensitivity
    % spec : specificity
    
    
    %% DETERMINATION OF THRESHOLDS BASED ON THE REFERENCE PAPERS
    
    threshold_nste = 0;
    threshold_ste = 0;
    
    % Using the model of in-hospital death - Granger
    % "Predictors of Hospital Mortality in the Global Registry of Acute
    % Coronary Events"
    
    if isequal(paper,'short') 
        
        % NSTEMI / UA
        % low - [1,108] <1%
        % intermediate - [109,140] 1-3%
        % high - [141,372] >3%
        
        % STEMI
        % low - [49,99] <4.5%
        % intermediate - [100,127] 4.5-11%
        % high - [128,263] >11%
        
        % Separation low/intermediate - high
        if separation == 1
            if isequal(type,'probabilities')
                threshold_nste = 0.04;
                threshold_ste = 0.11;
            else
                threshold_nste = 141;
                threshold_ste = 128;
            end
            
        % Separation low - intermediate/high
        elseif separation == 2
            if isequal(type,'probabilities')
                threshold_nste = 0.01;
                threshold_ste = 0.045;
            else
                threshold_nste = 109;
                threshold_ste = 100;
            end
            
        % this option basically uses the mean of the previous thresholds
        else
            if isequal(type,'probabilities')
                threshold_nste = 0.025;
                threshold_ste = 0.0280;
            else
                threshold_nste = 125;
                threshold_ste = 114;
            end
        end
        
    % Using the model of 6-months death - Fox
    % "Prediction of risk of death and myocardial infarction in the six
    % months after presentation with acute coronary syndrome:
    % prospective multinational observational study (GRACE)"
    
    elseif isequal(paper,'long') 
        
        % NSTEMI / UA
        % low - [1,88] <3%
        % intermediate - [89,118] 3-8%
        % high - [119,263] >8%
        
        % STEMI
        % low - [27,125] <2%
        % intermediate - [126,154] 2-5%
        % high - [155,319] >5%
        
        % Separation low/intermediate - high
        if separation == 1
            if isequal(type,'probabilities')
                threshold_nste = 0.09;
                threshold_ste = 0.06;
            else
                threshold_nste = 119;
                threshold_ste = 155;
            end
            
        % Separation low - intermediate/high
        elseif separation == 2
            if isequal(type,'probabilities')
                threshold_nste = 0.03;
                threshold_ste = 0.02;
            else
                threshold_nste = 89;
                threshold_ste = 126;
            end
            
        % this option basically uses the mean of the previous thresholds
        else
            
            if isequal(type,'probabilities')
                threshold_nste = 0.06;
                threshold_ste = 0.04;
            else
                threshold_nste = 104;
                threshold_ste = 140.5;
            end
        end
    end
    
    %% COMPUTATION OF EVALUATION METRICS
    
    % patients with NSTEMI or unstable angina
    idx_nste = find(diagnostico < 3);
    true_nste = true(idx_nste);
    grace_risk_nste = grace_risk(idx_nste);
    binary_predictions_nste = double(grace_risk_nste>= threshold_nste);
    % patients with STEMI
    idx_ste = find(diagnostico==3);
    true_ste = true(idx_ste);
    grace_risk_ste = grace_risk(idx_ste);
    binary_predictions_ste = double(grace_risk_ste>= threshold_ste);
        
    binary_predictions = [binary_predictions_nste , binary_predictions_ste];
    true = [true_nste ; true_ste];
    
    % get discrimination metrics
    [sens, spec, geom_mean, prec, f1score, ppv, npv] = discrimination_metrics(binary_predictions, true);
    
end