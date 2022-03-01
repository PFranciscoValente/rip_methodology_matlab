%%-----------------------------------------------------------------------
% SUMMARY STATISTICAL ANALYSIS OF THE ACS DATASET
% author: Francisco Valente (paulo.francisco.valente@gmail.com), 2020
%------------------------------------------------------------------------

clc
clear all
close all
format compact
warning('off','all')


%% REQUIRED INPUTS

% type > method for univariate statistical analysis
% options: 'standard' (uses chi-squared for categorical and kruskal-wallis for continuous), 
% 'coxregression' (uses Cox proportional-hazards model for all variables)
type = 'standard';

% days_of_followUp> follow-up time required in order to the patients enter in the study
% (only used if type='standard')
% options: '14days', '30days', '6months', '1year'
days_of_followUp = '30days';

% NOTE: For cox regression, it is used a minimum of 14 days follow-up and events in the 365 days
% (as it has information about censored observations). For standard analysis, 
% the period of events (events_days) is the same of the chosed days_of_followUp 


%% SELECT THE PATIENTS TO ANALYSE

[all_data,header,raw] = xlsread('ACS_DATASET') ;

all_data([93,760],:) = []; % don't consider these patients (too much missing data)

% note: 'events_days' is the period of time of events occurance

if isequal(type,'coxregression')
    [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 14 D'));
    events_days = 365;
else
    if isequal(days_of_followUp,'14days')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 14 D'));
        events_days = 14;
    elseif isequal(days_of_followUp,'30days')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 30 D'));
        events_days = 30;
    elseif isequal(days_of_followUp,'6months')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 180 D'));
        events_days = 180;
    elseif isequal(days_of_followUp,'1year')
        [~,idx_fup]= find(strcmp(header, 'FOLLOW-UP 365 D'));
        events_days = 365;
    end
end

patients_to_use = find(all_data(:,idx_fup)==1);
data = all_data(patients_to_use,:);

% label: event or not (death or myocardium infarction)
[~,idx_label_occurence]= find(strcmp(header, 'MORTE'));
events =  data(:,idx_label_occurence); % death or not
[~,idx_label_days]= find(strcmp(header, 'DIAS MORTE'));
days = data(:,idx_label_days); % days of death
label = zeros(length(patients_to_use),1);
% The label is positive if the patient dies before the period being analysed 
% (for example if the event_days=30 days and the patient dies at day 23)
idx_positive = find(days <= events_days & events==1);
label(idx_positive) = 1;

% CENSORED OBSERVATIONS (used in cox-regression analysis)
censored = zeros(1,length(days))';
survived = days>=events_days; % patients who survived more than 365 days
lost_fup = find(days < events_days & events==0); % pacientes que nao têm fup de 365 dias
censored(survived)=1;
censored(lost_fup)=1;

% GENERAL CHARACTERISTICS
num_patients = length(patients_to_use);
display(['total number of patients: ', num2str(num_patients)])
num_positive = sum(label(:)==1);
display(['total number of deaths: ', num2str(num_positive)])
num_negative = sum(label(:)==0);
display(['total number of survivals: ', num2str(num_negative)])

%% VARIABLES TO USE

[~,varFinal] = find(strcmp(header, 'REPERFUSÃO REALIZADA'));
data = data(:, [2:varFinal]); % do not consider the ID GERAL
feat_header = header(1,[2:varFinal]);

% NEW VARIABLES

% FUMADOR SEMPRE : fumador + não fumador 
[~,fumador] = find(strcmp(feat_header, 'FUMADOR'));
[~,exFumador] = find(strcmp(feat_header, 'EX-FUMADOR'));
data_fumadorSempre = [data(:,fumador) , data(:,exFumador)];
fumadorSempre = new_variable(data_fumadorSempre);
data = [data, fumadorSempre];
feat_header{1,size(feat_header,2)+1} = 'FUMADOR SEMPRE';
% DOENÇAS LIPIDICAS : colesterol + dislipidemia
[~,colesterol] = find(strcmp(feat_header, 'COLES-TEROL'));
[~,dislipidemia] = find(strcmp(feat_header, 'DISLIPI-DEMIA'));
[~,dataset_original] = find(strcmp(feat_header, 'DATASET'));
idx_stacruz = find(data(:,dataset_original)<3);
doencasLipidicas = [data(1:idx_stacruz(end),colesterol) ; data(idx_stacruz(end)+1:end,dislipidemia)];
data = [data, doencasLipidicas];
feat_header{1,size(feat_header,2)+1} = 'DOENÇAS LIPIDICAS';
% RISCOS CARDIACOS PREVIOS : doença arterial periferica + hipertensao
[~,dArtPeriferica] = find(strcmp(feat_header, 'DOENÇA ART. PERIFERICA'));
[~,hipertensao] = find(strcmp(feat_header, 'HIPER-TENSAO'));
data_riscosCardiacos = [data(:,dArtPeriferica) , data(:,hipertensao)];
riscosCardiacos = new_variable(data_riscosCardiacos);
data = [data, riscosCardiacos];
feat_header{1,size(feat_header,2)+1} = 'RISCOS CARDIACOS PREVIOS';
% RISCOS PREVIOS : fumador/exfumador + 
% colesterol/dislipidemia + d art periferica/hipertensao + diabetes
[~,diabetes] = find(strcmp(feat_header, 'DIABETES'));
data_riscosPrevios = [data(:,diabetes) , fumadorSempre, doencasLipidicas, riscosCardiacos];
riscosPrevios = new_variable(data_riscosPrevios);
data = [data, riscosPrevios];
feat_header{1,size(feat_header,2)+1} = 'RISCOS PREVIOS';
% ANTECEDENTES REPERFUSAO : antecedentes PTCA + CABG
[~,ptca] = find(strcmp(feat_header, 'PTCA'));
[~,cabg] = find(strcmp(feat_header, 'CABG'));
data_antecedentesReperfusao = [data(:,ptca) , data(:,cabg)];
antecedentesReperfusao = new_variable(data_antecedentesReperfusao);
data = [data, antecedentesReperfusao];
feat_header{1,size(feat_header,2)+1} = 'ANTECEDENTES REPERFUSÃO';
% ANTECEDENTES CARDIACOS : antecedentes AI + EAM
[~,eam] = find(strcmp(feat_header, 'EAM'));
[~,ai] = find(strcmp(feat_header, 'AI'));
data_antecedentesCardiacos = [data(:,ai) , data(:,eam)];
antecedentesCardiacos = new_variable(data_antecedentesCardiacos);
data = [data, antecedentesCardiacos];
feat_header{1,size(feat_header,2)+1} = 'ANTECEDENTES CARDIACOS';
% ANTECEDENTES EVENTOS CARDIACOS : antecedentes AI + EAM + PTCA +CABG
data_riscosPrevios = [antecedentesReperfusao , antecedentesCardiacos];
antecedentesEventosCardiacos = new_variable(data_riscosPrevios);
data = [data, antecedentesEventosCardiacos];
feat_header{1,size(feat_header,2)+1} = 'ANTECEDENTES EVENTOS CARDIACOS';

% REMOVE VARIABLES

[~,CC] = find(strcmp(feat_header, 'COLES-TEROL'));
data(:,CC) = [];
feat_header(:,CC) = [];
[~,DD] = find(strcmp(feat_header, 'DISLIPI-DEMIA'));
data(:,DD) = [];
feat_header(:,DD) = [];
[~,TT] = find(strcmp(feat_header, 'TIPO DE STEMI'));
data(:,TT) = [];
feat_header(:,TT) = [];


%% COMPUTE DISTRIBUITIONS AND STATISTICAL POWER OF EACH VARIABLE

feat_idx = []; % statistically significant features

% CHI-SQUARED AND KRUSKAL-WALLIS (standard analysis)

if isequal(type, 'standard')
    for i=1:size(data,2)

        display('-------------------------------------------------------------')
        display('-------------------------------------------------------------')
        
        FEATURE = feat_header{1,i}
        unique_values = unique(data(:,i));
        unique_values = unique_values(~isnan(unique_values));

        % CATEGORICAL VARIABLES
        
        if unique_values<5 % the categorical variables in the dataset have at most 4 different levels 
            
            % distributions
            display(':::::::::: distributions ::::::::::');
            
            for j=1:length(unique_values)
                
                % compute distributions of each category
                
                value = unique_values(j);
                display(['value: ',num2str(value)])
                % general information about the category
                cont = sum(data(:,i)==value);
                freq = cont/num_patients;
                display(['totais    >   ', 'contagem: ',num2str(cont),' ; frequencia: ',num2str(freq)]);
                % information about the negative samples (survivals) in the category
                cont0 = sum(data(:,i)==value & label==0);
                freq0 = cont0/num_negative;
                freq00 = cont0/cont;
                display(['vivos    >   ', 'contagem: ',num2str(cont0),' ; frequencia: ',num2str(freq0), ' | ', num2str(freq00)]);
                % information about the positive samples (deaths) in the category
                cont1 = sum(data(:,i)==value & label==1);
                freq1 = cont1/num_positive;
                freq11 = cont1/cont;
                display(['mortos    >   ', 'contagem: ',num2str(cont1),' ; frequencia: ',num2str(freq1), ' | ', num2str(freq11)]);

            end

            % statistical analysis 
            display(':::::::::: statistical significance ::::::::::');
            
            values = data(:,i)';
            all_nans = find(isnan(values)==1);
            values = values(~isnan(values)); %remove NaNs
            new_label = label;
            new_label(all_nans) = [];
            
            % chi-square test
            % H0: contigency table is independent in each dimension.
            % so if p>0.05, they are not indepedent, so the feature and label are dependent/correlated
            [table,chi2,p_chi2,table_labels] = crosstab(values, new_label); % create contigency table
            display(['chi-square test    >   ', 'p-value: ',num2str(p_chi2)]);
            
%             % correlation
%             [rho_corr,p_corr] = corr(values',new_label,'Type','Spearman');
%             display(['spearman correlation    >   ', 'p-value: ',num2str(p_corr),' ; rho: ',num2str(rho_corr)]);
            
            % fisher's exact test
            if length(unique_values) == 2 % fisher's test is only available for binary variables
                [h,p_fe,stats] = fishertest(crosstab(values, new_label));
                display(['fisher exact test    >   ', 'p-value: ',num2str(p_fe)]);
            end

            if p_chi2 <0.05 % guardar features com p_value<0.05
               feat_idx = [feat_idx i]; 
            end

        % CONTINUOUS VARIABLES 
        
        else
            
            values = data(:,i)';
            all_nans = find(isnan(values)==1);
            values = values(~isnan(values)); %remove NaNs
            new_label = label;
            new_label(all_nans) = [];
            alpha = 0.05;

            % normality assessment
            display(':::::::::: normality assessment ::::::::::');
            
            % lilliefors and shapiro-wilk tests: H0: data is normally distributed
            [h_lf,p_lf] = lillietest(values,'Alpha',alpha);
            [h_sw, p_sw,~] = swtest(values, alpha);
            display(['lilliefors test    >   ', 'p-value: ',num2str(p_lf),' ; h: ',num2str(h_lf)]);
            display(['shapiro-wilk test    >   ', 'p-value: ',num2str(p_sw),' ; h: ',num2str(h_sw)]);
            
            % figure()
            % histogram(values)
            % title(FEATURE)

            % distributions
            display(':::::::::: distributions ::::::::::');
            
            % general information about the variable
            med = median(values);
            interquartile = iqr(values);
            quartile25 = quantile(values,0.25);
            quartile75 = quantile(values,0.75);
            display(['totais    >   ', 'median: ',num2str(med),' ; quartile inferior: ',num2str(quartile25), ' - quartile superior: ',num2str(quartile75)]);
            % information about the negative samples (survivals) for the variable
            idx0 = find(new_label==0);
            idx1 = find(new_label==1);
            med0 = median(values(idx0));
            iqr0 = iqr(values(idx0));
            quartile25_0 = quantile(values(idx0),0.25);
            quartile75_0 = quantile(values(idx0),0.75);
            display(['vivos    >   ', 'median: ',num2str(med0),' ; quartile inferior: ',num2str(quartile25_0), ' - quartile superior: ',num2str(quartile75_0)]);
            % information about the positive samples (deaths) for the variable
            med1 = median(values(idx1));
            iqr1 = iqr(values(idx1));
            quartile25_1 = quantile(values(idx1),0.25);
            quartile75_1 = quantile(values(idx1),0.75);
            display(['mortos    >   ', 'median: ',num2str(med1),' ; quartile inferior: ',num2str(quartile25_1), ' - quartile superior: ',num2str(quartile75_1)]);

            % statistical analysis
            display(':::::::::: statistical significance ::::::::::');
            
%             Mann-Whitney U-test 
%             H0: non parametric test for independent samples and two groups
%             "Wilcoxon-Mann-Whitney test is a special case of the proportional odds ordinal logistic model"
%             [p_mw,h_mw] = ranksum(new_label,values);
%             display(['mann-whitney test    >   ', 'p-value: ',num2str(p_mw)]);

%             % logistic regression
%             [B,dev,stats] = mnrfit(values,new_label+1);
%             display(['logistic regression    >   ', 'p-value: ',num2str(stats.p(1))]);

            % Kruskal wallis test
            p_kw = kruskalwallis(values,new_label,'off');
            display(['kruskal wallis    >   ', 'p-value: ',num2str(p_kw)]);

            if p_kw<0.05 % guardar features com p_value<0.05
                 feat_idx = [feat_idx i];
            end
         
        end

        % MISSING VALUES
        
        display(':::::::::: missing values ::::::::::')
        nans = sum(isnan(data(:,i)));
        freq_nans = nans/num_patients;
        display(['contagem: ',num2str(nans),' ; frequencia: ',num2str(freq_nans)]);

    end

% COX REGRESSION

elseif isequal (type, 'coxregression')
    
    for i=1:size(data,2)

        display('-------------------------------------------------------------')
        FEATURE = feat_header{1,i}
            
        [b,logl,H,stats] = coxphfit(data(:,i),days,'Censoring',censored);
        % Calculate 95% confidence interval of Hazard Ratio
        estimate = exp(b);
        CI = exp(b + [-1 1]*1.96*stats.se); % 95% confidence inteval of estimate
        display('::: analysis by Cox hazards regression :::');
        display(['coefficient > ', 'estimate: ',num2str(estimate), ' ; 95% confidence interval: [', num2str(CI(1)), ' ',num2str(CI(2)), ']']);
        display(['p value: ',num2str(stats.p)]);
        
        if stats.p<0.05 % guardar features com p_value<0.05
             feat_idx = [feat_idx i];
        end
        
    end    
end


%% COMPUTE CORRELATION BETWEEN SIGNIFICANT VARIABLES (p_value<0.05)

feat_correlations = {}; % name of the features
pvalues_correlation = []; 
correlations = []; % correlation values

for j=1:length(feat_idx)
    for k=1:length(feat_idx)
        
        if j<k
            
            % feature 1 (j)
            FEATURE1 = feat_header{1,feat_idx(j)};
            values1 = data(:,feat_idx(j))';
            % feature 2 (k)
            FEATURE2 = feat_header{1,feat_idx(k)};
            values2 = data(:,feat_idx(k))';
            
            % name of the features in the correlation j-k
            feat_correlations{j,k} = [FEATURE1,'-',FEATURE2];

            % remove NaNs
            all_nans1 = find(isnan(values1)==1);
            all_nans2 = find(isnan(values2)==1);
            nans_unique = unique([all_nans1,all_nans2]);
            values1(nans_unique) = [];
            values2(nans_unique) = [];
            
            % compute correlation            
            [rho,p_val] = corr(values1',values2','Type','Spearman');
            pvalues_correlation(j,k) = p_val;
            correlations(j,k) = rho;
        end      
    end
end