%------------------------------------------------------------------------
% FILE USED TO PLOT MORTALITY AND RELIABILITY DATA
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function plots_results(type,data)
    
    % INPUTS
    % type : what data to plot, reliability or mortality
    % data : result values
    
    % IMPORTANT NOTE: the intervals chosed for mortality and reliability plot MUST
    % agree with the intervals used to colect the data

    %% MORTALITY
    
    if isequal(type,'mortality')

        mortality_rates = data;
        
        % create error bars values
        quartile25 = quantile(mortality_rates,0.25);
        low_error = nanmedian(mortality_rates)-quartile25;
        quartile75 =quantile(mortality_rates,0.75);
        high_error = quartile75-nanmedian(mortality_rates);

        % statistical analysis of the discrete group of values (different intervals)
        labels_mortality = []; % create artificial label, basically a label per category
        values_mortality = [];
        for jj = 1:size(mortality_rates,2)
            values_mortality = [values_mortality; mortality_rates(:,jj)];
            labels_mortality = [labels_mortality; ones(length(mortality_rates(:,jj)),1)*jj];
        end
        [~,~,p_chi2_mortality,~] = crosstab(values_mortality, labels_mortality);

        % PLOT 
        
        figure()
        errorbar(1:size(mortality_rates,2),nanmean(mortality_rates),low_error,high_error,'--o','Color',[0 0.4470 0.7410])

        % x ticks
        xticks(1:size(mortality_rates,2))
        xticknames = {'[0-10[','[10-20[','[20-30[','[30-40[','[40-50[','[50-60[', '[60-100]'};
        xticklabels(xticknames(1:size(mortality_rates,2)))
        xlim([0.5,size(mortality_rates,2)+0.5]);
        ylim([-2.5 40]);
        ax = gca;
        ax.FontSize = 12; 
        % text 
        x = xlabel ('Predicted Risk (%)');
        set(x,'FontSize',12);
        set(x,'FontWeight','bold');
        y = ylabel ('Mortality Rate (%)');
        set(y,'FontSize',12);
        set(y,'FontWeight','bold');
%         text(4,37,sprintf('p-value (chi-squared test):\n%0.4g ',p_chi2_mortality))
        text(2.5,35,'p-value (chi-squared test): <0.0001 ','FontSize',14);
    end
    
    %% RELIABILITY
    
    if isequal(type,'reliability')

        reliability_rates = data;

        % create error bars values
        quartile25 = quantile(reliability_rates,0.25);
        low_error = nanmedian(reliability_rates)-quartile25;
        quartile75 =quantile(reliability_rates,0.75);
        high_error = quartile75-nanmedian(reliability_rates);

        % statistical analysis of the discrete group of values (different intervals)
        labels_reliability = []; % create artificial label, basically a label per category
        values_reliability = [];
        for jj = 1:size(reliability_rates,2)
            values_reliability = [values_reliability; reliability_rates(:,jj)];
            labels_reliability = [labels_reliability; ones(length(reliability_rates(:,jj)),1)*jj];
        end
        [~,~,p_chi2_reliability,~] = crosstab(values_reliability, labels_reliability)

        % PLOT 
        ci = confidence_interval(reliability_rates);
        
        figure()
        errorbar(1:size(reliability_rates,2),nanmean(reliability_rates),ci(1),ci(2),'--o','Color',[0 0.4470 0.7410])

        % x ticks
        xticks(1:size(reliability_rates,2))
        xticknames = {'[0-10[','[10-20[','[20-30[','[30-40[','[40-50[','[50-60[','[60-70[','[70-100]'};
        xticklabels(xticknames(1:size(reliability_rates,2)))
        xlim([0.5,size(reliability_rates,2)+0.5]);
        ylim([-2.5 50]);
        ax = gca;
        ax.FontSize = 11;
        % text 
        x = xlabel ('Reliability (%)');
        y = ylabel ('Misclassification Rate (%)');
        set(y,'FontSize',12);
        set(y,'FontWeight','bold');
        set(x,'FontSize',12);
        set(x,'FontWeight','bold');
%         title ('Relation between predicted reliability and misclassification rate');
%         text(4,60,sprintf('p-value (chi-squared test):\n%0.4g ',p_chi2_reliability))
        text(3,45,'p-value (chi-squared test): <0.0001 ','FontSize',14)
    end
end