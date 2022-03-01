%%-----------------------------------------------------------------------
% FILE TO PRODUCE CALIBRATION PLOTS
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function calibration_plot(tests_x,tests_y, method)

%     % TRAIN
%     
%     X = mean(trains_x);
%     Y = mean(trains_y);
%     
%     figure()
%     plot(X,Y,'.')
%     hold on
%     max1 = max([max(X) max(Y)]);
%     plot([0 max1],[0 max1])
    
    % TEST
        
    X = mean(tests_x);
    Y = mean(tests_y);
    
    x_ci = confidence_interval(tests_x);
    y_ci = confidence_interval(tests_y);
    
    errX = X-x_ci(1,:);
    errY = Y-y_ci(1,:);
    
    X = X*100;
    Y = Y*100;
    errX = errX*100;
    errY = errY*100;
    
     % slope and intercept
    P = polyfit(mean(tests_x),mean(tests_y),1);
    slope = P(1);
    intercept = P(2);
    
    
    figure()
    max1 = max([max(X) max(Y)]);
    max1 = max1+5;
    
    plot([0 max1],[0 max1], 'Color',[0 0.4470 0.7410])
    hold on
    plot(X,Y, '.-', 'Color',[0.8500 0.3250 0.0980], 'MarkerSize', 10)    
    
    hold on
    plot(NaN,NaN,'display','', 'linestyle', 'none')
    hold on
    plot(NaN,NaN,'display','', 'linestyle', 'none')
    hold on
%     plot(X,Y,'--o')
    h1 = errorbar(X, Y, errX, 'horizontal', '--', 'Color',[0.8500 0.3250 0.0980]);
    hold on
    h2 = errorbar(X, Y, errY, '--', 'Color',[0.8500 0.3250 0.0980]);
    
%     legend( sprintf('%f C', 2), sprintf('%f C', 1) )
    
    hold off
    
    xlim([0 max1]);
    ylim([0 max1]);
%     h1.Color = [h1.Color, 0.1]; % mudar transparencia

    % Set transparency level (0:1)
    alpha = 0.2;   
    % Set transparency (undocumented)
    set([h1.Bar, h1.Line], 'ColorType', 'truecoloralpha', 'ColorData', [h1.Line.ColorData(1:3); 255*alpha]);
    set([h2.Bar, h2.Line], 'ColorType', 'truecoloralpha', 'ColorData', [h2.Line.ColorData(1:3); 255*alpha]);
    
    h3 = legend('Ideal', 'Calibration', ['slope: ', num2str(round(slope,3))], ['intercept: ', num2str(round(intercept,3))], 'Location','southeast');    

    xlabel('Predicted risk (%)');
    ylabel('Mortality rate (%)');

    title(method);

end 