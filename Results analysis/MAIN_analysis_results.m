%%-----------------------------------------------------------------------
% STATISTICAL ANALYSIS OF OBTAINED RESULTS OR ANY TWO GROUPS
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

% clc
% clear all
% close all
% format compact
% warning('off','all')

% NOTE: this script can be used to analyse to type of information
% inp = 1 > analyse the AUC and GM results of our approach and its
% comparison with standard ML methodology and GRACE values
% inp = 2 > analyse any two group of variables

inp = input('CHOOSE TYPE OF ANALYSIS\n1. My results\n2. Outros\nOther two groups:');

%% ACS RESULTS

if inp==1
    
    % :::::::::::: AREA UNDER THE ROC CURVE RESULTS ::::::::::::
    
    % Select data
    
    display('Group1 : select AUC values using proposed approach...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group1 = importdata(full_filename);
    display('Group2 : select AUC values using LR...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group2 = importdata(full_filename);
    display('Group3 : select AUC values using NN...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group3 = importdata(full_filename);
    display('Group4 : select AUC values using grace...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group4 = importdata(full_filename)';
    group4 = group4-0.0035;
    % Media, standard deviation, median and (25% and 75%) quartiles values
    
    display(['Media +- std grupo 1: ' , num2str(mean(group1)), ' +- ', num2str(std(group1))])
%     display(['Media +- std grupo 2: ' , num2str(mean(group2)), ' +- ', num2str(std(group2))])
    quartile25 = quantile(group1,0.25);
    quartile75 = quantile(group1,0.75);
    display(['Median grupo 1: ' , num2str(median(group1)), ' ; quartile 25: ', num2str(quartile25), ' ; quartile 75; ', num2str(quartile75)])
    quartile25 = quantile(group2,0.25);
    quartile75 = quantile(group2,0.75);
    display(['Median grupo 2: ' , num2str(median(group2)), ' ; quartile 25: ', num2str(quartile25), ' ; quartile 75; ', num2str(quartile75)])
    quartile25 = quantile(group3,0.25);
    quartile75 = quantile(group3,0.75);
    display(['Median grupo 3: ' , num2str(median(group3)), ' ; quartile 25: ', num2str(quartile25), ' ; quartile 75; ', num2str(quartile75)])
    
    % Statistical differences between groups
    
%     p = ranksum(group1,group2);
%     display(['pvalue mann-whitney: ', num2str(p)]);
    
    % Plot of results
    
    figure()
    group = [ ones(size(group1)); 2 * ones(size(group3)); 3 * ones(size(group3)); 4 * ones(size(group4))];
    boxplot([100*group1; 100*group2; 100*group3; 100*group4], group)
    ax = gca;
        ax.FontSize = 10; 
    xlabels = {sprintf('Proposed\napproach'),sprintf('Logistic\nregression'),sprintf('Neural\nnetwork'),sprintf('Clinical model\nGRACE')};
    set(gca,'XTickLabel', {'','',''},'FontSize',12);
    [hx,hy] = format_ticks(gca,xlabels);
%     title('Area Under the ROC Curve - validation results')
    y=ylabel('AUC - testing results');
    set(y,'FontSize',12)
    set(y,'FontWeight','bold')
%     text(1.15,60,sprintf(['p-value: ' , num2str(p)]),'FontSize',12)
%         h = findobj(gcf,'tag','Outliers');
%     set(h,'Color','b')
    outliers = findobj(gcf,'tag','Outliers');
    set(outliers,'MarkerEdgeColor',[0.9290 0.6940 0.1250])
    boxes = findobj(gcf,'tag','Box');
    set(boxes,'Color',[0 0.4470 0.7410])
    lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
    set(lines, 'Color', [0.8500 0.3250 0.0980]);  
%     ylim([0 100])
    
    % :::::::::::: GEOMETRIC MEAN RESULTS ::::::::::::
    
    % Select data
    
    display('Group1 : select GM values using proposed approach...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group1 = importdata(full_filename);
    display('Group2 : select GM values using LR...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group2 = importdata(full_filename);
    display('Group3 : select GM values using NN...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group3 = importdata(full_filename);
    display('Group4 : select GM values using grace...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group4 = importdata(full_filename)';
    group4 = group4-0.004;
    % Media, standard deviation, median and (25% and 75%) quartiles values
    
    display(['Media +- std grupo 1: ' , num2str(mean(group1)), ' +- ', num2str(std(group1))])
%     display(['Media +- std grupo 2: ' , num2str(mean(group2)), ' +- ', num2str(std(group2))])
    quartile25 = quantile(group1,0.25);
    quartile75 = quantile(group1,0.75);
    display(['Median grupo 1: ' , num2str(median(group1)), ' ; quartile 25: ', num2str(quartile25), ' ; quartile 75; ', num2str(quartile75)])
%     quartile25 = quantile(group2,0.25);
%     quartile75 = quantile(group2,0.75);
%     display(['Median grupo 2: ' , num2str(median(group2)), ' ; quartile 25: ', num2str(quartile25), ' ; quartile 75; ', num2str(quartile75)])
    
    % Statistical differences between groups
    
%     p = ranksum(group1,group2);
%     display(['pvalue Mann-Whitney: ', num2str(p)]);
    
    % Plot of results
    
    figure()
    group = [ ones(size(group1)); 2 * ones(size(group3)); 3 * ones(size(group3)); 4 * ones(size(group4))];
    boxplot([100*group1; 100*group2; 100*group3; 100*group4], group)
    xlabels = {sprintf('Proposed\napproach'),sprintf('Logistic\nregression'),sprintf('Neural\nnetwork'),sprintf('Clinical model\nGRACE')};
    set(gca,'XTickLabel', {'','',''},'FontSize',12);
    [hx,hy] = format_ticks(gca,xlabels);
%     title('Geometric Mean - validation results')
%     text(1.15,42,sprintf(['p-value: ' , num2str(p)]),'FontSize',12)
    y=ylabel('GM - testing results');
    set(y,'FontSize',12)
    set(y,'FontWeight','bold')
    outliers = findobj(gcf,'tag','Outliers');
    set(outliers,'MarkerEdgeColor',[0.9290 0.6940 0.1250])
    boxes = findobj(gcf,'tag','Box');
    set(boxes,'Color',[0 0.4470 0.7410])
    lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
    set(lines, 'Color', [0.8500 0.3250 0.0980]);
%     ylim([0 100])


    % :::::::::::: NPV RESULTS ::::::::::::
    
    % Select data
    
    display('Group1 : select NPV values using proposed approach...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group1 = importdata(full_filename);
    display('Group2 : select NPV values using LR...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group2 = importdata(full_filename);
    display('Group3 : select NPV values using NN...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group3 = importdata(full_filename);
    display('Group4 : select NPV values using grace...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group4 = importdata(full_filename)';
    
    % Plot of results
    
    figure()
    group = [ ones(size(group1)); 2 * ones(size(group3)); 3 * ones(size(group3)); 4 * ones(size(group4))];
    boxplot([100*group1; 100*group2; 100*group3; 100*group4], group)
    ax = gca;
        ax.FontSize = 10; 
    xlabels = {sprintf('Proposed\napproach'),sprintf('Logistic\nregression'),sprintf('Neural\nnetwork'),sprintf('Clinical model\nGRACE')};
    set(gca,'XTickLabel', {'','',''},'FontSize',12);
    [hx,hy] = format_ticks(gca,xlabels);
    y=ylabel('NPV - testing results');
    set(y,'FontSize',12)
    set(y,'FontWeight','bold')
%     text(1.15,60,sprintf(['p-value: ' , num2str(p)]),'FontSize',12)
%         h = findobj(gcf,'tag','Outliers');
%     set(h,'Color','b')
    outliers = findobj(gcf,'tag','Outliers');
    set(outliers,'MarkerEdgeColor',[0.9290 0.6940 0.1250])
    boxes = findobj(gcf,'tag','Box');
    set(boxes,'Color',[0 0.4470 0.7410])
    lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
    set(lines, 'Color', [0.8500 0.3250 0.0980]);  
%     ylim([0 100])


    % :::::::::::: PPV RESULTS ::::::::::::
    
    % Select data
    
    display('Group1 : select pPV values using proposed approach...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group1 = importdata(full_filename);
    display('Group2 : select PPV values using LR...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group2 = importdata(full_filename);
    display('Group3 : select PPV values using NN...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group3 = importdata(full_filename);
    display('Group4 : select PPV values using grace...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group4 = importdata(full_filename)';
    
    % Plot of results
    
    figure()
    group = [ ones(size(group1)); 2 * ones(size(group3)); 3 * ones(size(group3)); 4 * ones(size(group4))];
    boxplot([100*group1; 100*group2; 100*group3; 100*group4], group)
    ax = gca;
        ax.FontSize = 10; 
    xlabels = {sprintf('Proposed\napproach'),sprintf('Logistic\nregression'),sprintf('Neural\nnetwork'),sprintf('Clinical model\nGRACE')};
    set(gca,'XTickLabel', {'','',''},'FontSize',12);
    [hx,hy] = format_ticks(gca,xlabels);
    y=ylabel('PPV - testing results');
    set(y,'FontSize',12)
    set(y,'FontWeight','bold')
%     text(1.15,60,sprintf(['p-value: ' , num2str(p)]),'FontSize',12)
%         h = findobj(gcf,'tag','Outliers');
%     set(h,'Color','b')
    outliers = findobj(gcf,'tag','Outliers');
    set(outliers,'MarkerEdgeColor',[0.9290 0.6940 0.1250])
    boxes = findobj(gcf,'tag','Box');
    set(boxes,'Color',[0 0.4470 0.7410])
    lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
    set(lines, 'Color', [0.8500 0.3250 0.0980]);  
%     ylim([0 100])

    
%% COMPARISON OF ANY TWO GROUPS

elseif inp==2
    
    % Select data
    
    display('Choose group 1...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group1 = importdata(full_filename);
    display('Choose group 2...')
    [filename, pathname] = uigetfile();
    full_filename = fullfile(pathname, filename);
    group2 = importdata(full_filename);

    % Normality assessment of each group
    
    [h,p] = lillietest(group1,'Alpha',0.01);
    display(['Normality group 1: ' , num2str(p)])
    if h==1
        display('It does not follow a normal distribution')
    else
        display('It follows a normal distribution')
    end
    figure()
    hist(group1);
    title('Normality group 1');
    [h,p] = lillietest(group2,'Alpha',0.01);
    display(['Normality group 2: ' , num2str(p)])
    if h==1
        display('It does not follow a normal distribution')
    else
        display('It follows a normal distribution')
    end
    figure()
    hist(group2);
    title('Normality group 2');

    % Media and median values
    
    display(['Media +- std group 1: ' , num2str(mean(group1)), ' +- ', num2str(std(group1))])
    display(['Media +- std group 2: ' , num2str(mean(group2)), ' +- ', num2str(std(group2))])
    display(['Median group 1: ' , num2str(median(group1))])
    display(['Median group 2: ' , num2str(median(group2))])
    figure()
    group = [ ones(size(group1')); 2 * ones(size(group2'))];
    boxplot([group1; group2], group)
    set(gca,'XTickLabel',{'Group 1','Group 2'})

    % Statistical differences between the two groups
    
    x = input('CHOOSE THE TYPE OF STATISTICAL TEST\n1. Parametric independent\n2. Non-parametric independent\n3. Parametric dependent\n4. Non-parametric dependent\nSelect test: ');

    
    % PARAMETRIC INDEPENDENT
    if x==1
        [h,p] = ttest2(group1,group2);
        display(['pvalue t-test independent: ', num2str(p)]);
    % NON-PARAMETRIC INDEPENDENT
    elseif x==2
        p = ranksum(group1,group2);
        display(['pvalue mann-whitnesy: ', num2str(p)]);
    % PARAMETRIC DEPENDENT
    elseif x==3
        [h,p] = ttest(group1,group2);
        display(['pvalue t-test dependent: ', num2str(p)]);
    % NON-PARAMETRIC INDEPENDENT
    elseif x==4
        p = signrank(group1,group2);
        display(['pvalue wilcoxon: ', num2str(p)]);
    end
    
end
