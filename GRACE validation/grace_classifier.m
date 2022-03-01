%------------------------------------------------------------------------
% Auxiliary function to get the risk factors' values used to compute the 
% GRACE score and get the desired GRACE output (in terms of score or probability)
% author: Francisco Valente (paulo.francisco.valente@gmail.com), 2020
%------------------------------------------------------------------------

function [results] = grace_classifier(feat_header, features, paper, type)
    
    %% PARAMETERS 
    
    % N - number of samples (patients)
    % P - number of features
    
    % INPUTS
    % feat_header
    % features : NxP matrix of feature values
    % paper : original paper used for computation ('short' > Granger,in-hospital ; 'long' > Fox, 6-months)
    % type : type of GRACE result output (score or probability)

    % OUTPUTS
    % result: score or probability computed using Grace model
    
    
    %% SELECT GRACE FEATURES
    
    [~,idx_age]= find(strcmp(feat_header, 'IDADE'));
    [~,idx_sbp]= find(strcmp(feat_header, 'PRESSAO SISTOLICA'));
    [~,idx_hr]= find(strcmp(feat_header, 'FREQUENCIA CARDIACA'));
    [~,idx_killip]= find(strcmp(feat_header, 'CLASSE KILLIP'));
    [~,idx_stsd]= find(strcmp(feat_header, 'DESVIOS ST'));
    [~,idx_ecm]= find(strcmp(feat_header, 'BIOM. LESAO CARDIACA'));
    [~,idx_cc]= find(strcmp(feat_header, 'CREATININA'));
    [~,idx_caa]= find(strcmp(feat_header, 'PARAGEM CARD. ADMISS.'));

    grace_all = [];

    %% COMPUTE GRACE RESULT FOR ALL PATIENTS
    
    for ind=1:length(features)

        age = features(ind,idx_age);
        sbp = features(ind,idx_sbp);
        hr = features(ind,idx_hr);
        killip = features(ind,idx_killip);
        stsd = features(ind,idx_stsd);
        ecm = features(ind,idx_ecm);
        cc = features(ind,idx_cc);
        caa = features(ind,idx_caa);
       
        score =  grace_score(age,sbp,hr,killip,stsd,ecm,cc,caa, paper);
        
        if isequal(type,'probabilities')
            result = convert_grace_probability(score, paper);
        else
            result = score;
        end

        grace_all = [grace_all result];        
    end
    results = grace_all;
    
end