%------------------------------------------------------------------------
% File to compute the GRACE score (system of points)
% author: Francisco Valente (paulo.francisco.valente@gmail.com), 2020
%------------------------------------------------------------------------

function [score] = grace_score(age,sbp,hr,killip,stsd,ecm,cc,caa, paper)
    
    %% PARAMETERS 
   
    % INPUTS
    
    % > variables used in GRACE model, by the following order:
    % age; systolic blood pressure (sbp); heart rate (hr); killip class; 
    % st segment deviation (stsd); elevated cardiac markers (ecm); 
    % creatinine concentration (cc); cardiac arresst at admission (caa)
    
    % > paper:
    % if 'short' : use the model of in-hospital death - Granger
    % if 'long' : use the model of 6-months death - Fox
    
    % OUTPUTS
    % Score computed using Grace model
    
    %% COMPUTATION OF GRACE SCORE
    
    score = 0;
    
    % Using the model of in-hospital death - Granger
    % "Predictors of Hospital Mortality in the Global Registry of Acute
    % Coronary Events"
    
    if isequal(paper,'short') 
        
        if (age<=30)
            score = score+0;
        elseif (age>30 & age<40)
            score = score+0;
        elseif (age>=40 & age<50)
            score = score+18;
        elseif (age>=50 & age<60)
            score = score+36;
        elseif (age>=60 & age<70)
            score = score+55;
        elseif (age>=70 & age<80)
            score = score+73;
        elseif (age>=80 & age<90)
            score = score+91;
        elseif (age>=90)
            score = score+100;
        end

        if (hr<=50)
            score = score+0;
        elseif (hr>50 & hr<70)
            score = score+3;
        elseif (hr>=60 & hr<90)
            score = score+9;
        elseif (hr>=90 & hr<110)
            score = score+15;
        elseif (hr>=110 & hr<150)
            score = score+24;
        elseif (hr>=150 & hr<200)
            score = score+38;
        elseif (hr>=200)
            score = score+46;
        end

        if (sbp<=80)
            score = score+58;
        elseif (sbp>80 & sbp<100)
            score = score+53;
        elseif (sbp>=100 & sbp<120)
            score = score+43;
        elseif (sbp>=120 & sbp<140)
            score = score+34;
        elseif (sbp>=140 & sbp<160)
            score = score+24;
        elseif (sbp>=160 & sbp<200)
            score = score+10;
        elseif (sbp>=200)
            score = score+0;
        end

        if (cc<0.4)
            score = score+1;
        elseif (cc>=0.4 & cc<0.8)
            score = score+4;
        elseif (cc>=0.8 & cc<1.2)
            score = score+7;
        elseif (cc>=1.2 & cc<1.6)
            score = score+10;
        elseif (cc>=1.6 & cc<2)
            score = score+13;
        elseif (cc>=2 & cc<4)
            score = score+21;
        elseif (cc>=4)
            score = score+28;
        end

        if killip == 1
            score = score+0;
        elseif killip == 2
            score = score+20;
        elseif killip == 3
            score = score+39;
        elseif killip == 4
            score = score+59;
        end  

        if caa == 1
            score = score+39;
        else
            score = score+0;
        end

        if ecm == 1
            score = score+14;
        else
            score = score+0;
        end

        if stsd == 1        
            score = score+28;
        else
            score = score+0;
        end
        
    % Using the model of 6-months death - Fox
    % "Prediction of risk of death and myocardial infarction in the six
    % months after presentation with acute coronary syndrome:
    % prospective multinational observational study (GRACE)"
    
    elseif isequal(paper,'long') 
        
        if (age<35)
            score = score+0;
        elseif (age>=35 & age<45)
            score = score+0+(age-35)*1.8;
        elseif (age>=45 & age<55)
            score = score+18+(age-45)*1.8;
        elseif (age>=55 & age<65)
            score = score+36+(+age-55)*1.8;
        elseif (age>=65 & age<75)
            score = score+54+(age-65)*1.9;
        elseif (age>=75 & age<85)
            score = score+73+(age-75)*1.8;
        elseif (age>=85 & age<90)
            score = score+91+(age-85)*1.8;
        elseif (age>=90)
            score = score+100;
        end

        if (hr<70)
            score = score+0;
        elseif (hr>=70 & hr<80)
            score = score+0+(hr-70)*0.3;
        elseif (hr>=80 & hr<90)
            score = score+3+(hr-80)*0.2;
        elseif (hr>=90 & hr<100)
            score = score+5+(hr-90)*0.3;
        elseif (hr>=100 & hr<110)
            score = score+8+(hr-100)*0.2;
        elseif (hr>=110 & hr<150)
            score = score+10+(hr-110)*0.3;
        elseif (hr>=150 & hr<200)
            score = score+22+(hr-150)*0.3;
        elseif (hr>=200)
            score = score+34;
        end

        if (sbp<80)
            score = score+40;
        elseif (sbp>=80 & sbp<100)
            score = score+40-(sbp-80)*0.3;
        elseif (sbp>=100 & sbp<110)
            score = score+34-(sbp-100)*0.3;
        elseif (sbp>=110 & sbp<120)
            score = score+31-(sbp-110)*0.4;
        elseif (sbp>=120 & sbp<130)
            score = score+27-(sbp-120)*0.3;
        elseif (sbp>=130 & sbp<140)
            score = score+24-(sbp-130)*0.3;
        elseif (sbp>=140 & sbp<150)
            score = score+20-(sbp-140)*0.4;
        elseif (sbp>=150 & sbp<160)
            score = score+17-(sbp-150)*0.3;
        elseif (sbp>=160 & sbp<180)
            score = score+14-(sbp-160)*0.3;
        elseif (sbp>=180 & sbp<200)
            score = score+8-(sbp-180)*0.4;
        elseif (sbp>=200)
            score = score+0;
        end

        if (cc<0.2)
            score = score+0+(cc-0)*(1/0.2);
        elseif (cc>=0.2 & cc<0.4)
            score = score+1+(cc-0.2)*(2/0.2);
        elseif (cc>=0.4 & cc<0.6)
            score = score+3+(cc-0.4)*(1/0.2);
        elseif (cc>=0.6 & cc<0.8)
            score = score+4+(cc-0.6)*(2/0.2);
        elseif (cc>=0.8 & cc<1)
            score = score+6+(cc-0.8)*(1/0.2);
        elseif (cc>=1 & cc<1.2)
            score = score+7+(cc-1)*(1/0.2);
        elseif (cc>=1.2 & cc<1.4)
            score = score+8+(cc-1.2)*(2/0.2);
        elseif (cc>=1.4 & cc<1.6)
            score = score+10+(cc-1.4)*(1/0.2);
        elseif (cc>=1.6 & cc<1.8)
            score = score+11+(cc-1.6)*(2/0.2);
        elseif (cc>=1.8 & cc<2)
            score = score+13+(cc-1.8)*(1/0.2);
        elseif (cc>=2 & cc<3)
            score = score+14+(cc-2)*(7/1);
        elseif (cc>=3 & cc<4)
            score = score+21+(cc-3)*(7/1);
        elseif (cc>=4)
            score = score+28;
        end

        if killip == 1
            score = score+0;
        elseif killip == 2
            score = score+15;
        elseif killip == 3
            score = score+29;
        elseif killip == 4
            score = score+44;
        end  

        if caa == 1
            score = score+30;
        else
            score = score+0;
        end

        if ecm == 1
            score = score+13;
        else
            score = score+0;
        end

        if stsd == 1        
            score = score+17;
        else
            score = score+0;
        end
    
    end
    
end