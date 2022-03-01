%%-----------------------------------------------------------------------
% File to obtain the rates of mortality for each GRACE stratification group
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function rates_mortality(grace_risk, true, diagnostico)
    
    threshold_nste_lowint = 0.01;
    threshold_ste_lowint = 0.045;
    threshold_nste_inthigh = 0.04;
    threshold_ste_inthigh = 0.11;
    
    % patients with NSTEMI or unstable angina
    idx_nste = find(diagnostico < 3);
    true_nste = true(idx_nste);
    grace_nste = grace_risk(idx_nste);
    % patients with STEMI
    idx_ste = find(diagnostico==3);
    true_ste = true(idx_ste);
    grace_ste = grace_risk(idx_ste);
    
    % divide in categories
    grace_nste_low = find(grace_nste<threshold_nste_lowint);
    grace_nste_int = find(grace_nste>=threshold_nste_lowint & grace_nste<threshold_nste_inthigh);
    grace_nste_high = find(grace_nste>=threshold_nste_inthigh);
    grace_ste_low = find(grace_ste<threshold_ste_lowint);
    grace_ste_int = find(grace_ste>=threshold_ste_lowint & grace_ste<threshold_ste_inthigh);
    grace_ste_high = find(grace_ste>=threshold_ste_inthigh);
    
    % trues of each category
    true_nste_low = true_nste(grace_nste_low);
    true_nste_int = true_nste(grace_nste_int);
    true_nste_high = true_nste(grace_nste_high);
    true_ste_low = true_ste(grace_ste_low);
    true_ste_int = true_ste(grace_ste_int);
    true_ste_high = true_ste(grace_ste_high);
    
    % death rates
    display('death rates per category')
    rate_nste_low = sum(true_nste_low)/length(true_nste_low)*100
    rate_nste_int = sum(true_nste_int)/length(true_nste_int)*100
    rate_nste_high = sum(true_nste_high)/length(true_nste_high)*100
    rate_ste_low = sum(true_ste_low)/length(true_ste_low)*100
    rate_ste_int = sum(true_ste_int)/length(true_ste_int)*100
    rate_ste_high = sum(true_ste_high)/length(true_ste_high)*100
    
    % death rates combined
    sum_low = sum(true_nste_low)+sum(true_ste_low);
    sum_int = sum(true_nste_int)+sum(true_ste_int);
    sum_high = sum(true_nste_high)+sum(true_ste_high);
    length_low = length(true_nste_low)+length(true_ste_low);
    length_int = length(true_nste_int)+length(true_ste_int);
    length_high = length(true_nste_high)+length(true_ste_high);
    rates_low = sum_low/length_low*100
    rates_int = sum_int/length_int*100
    rates_high = sum_high/length_high*100
    
end