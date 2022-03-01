%%-----------------------------------------------------------------------
% File to plot decision rules created using centroids
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------

function visualize_centroids(data, labels, centroid_negative, centroid_positive, name_feature)

    idx_negative = find(labels==0);
    idx_positive = find(labels==1);
    feat_negative = data(idx_negative);  % positive data
    feat_positive = data(idx_positive); % negative data
    
    my_centroid_negative = round(centroid_negative,2);
    my_centroid_positive = round(centroid_positive,2);
    threshold = mean([my_centroid_positive,my_centroid_negative]);
    
    figure
    % PLOT 1
    subplot(2,1,1)
    p2 = plot(centroid_negative,0,'*', 'Color',[0.4660 0.6740 0.1880],'MarkerSize',15,'LineWidth', 2);
    hold on
    p4 = plot(centroid_positive,1, 'o','Color',[0.4660 0.6740 0.1880],'MarkerSize',15,'LineWidth', 2);
    hold on
    p1 = plot(feat_negative,0, '*','Color',[0 0.4470 0.7410]);
    hold on
    p3 = plot(feat_positive,1, 'o','Color',[0.8500 0.3250 0.0980]);
    hold on
    p5 = xline(threshold,'Color',[0.4660 0.6740 0.1880], 'LineWidth',1.5);
    hold off
    txt = num2str(my_centroid_negative);
    text(my_centroid_negative,0.2,txt,'FontSize',10)
    txt = num2str(my_centroid_positive);
    text(my_centroid_positive,0.8,txt,'FontSize',10)
    txt = ['Threshold: ', num2str(threshold)];
    text(threshold+0.1,0.5,txt,'FontSize',10);
    xlabel('Feature value')
    ylabel('Label')
    yticks([0 1])
    h = [p1(1),p2,p3(1),p4,p5(1)];
    legend(h,'negative cluster','positive cluster','negative points','positive points');
    title('All points and obtained clusters');

    % PLOT 2

    % sort labels according to normalized distances
    d_negative = dist( data, centroid_negative, 2);
    d_positive = dist( data, centroid_positive, 2);
    d_normalized = 1 - (d_positive./(d_positive+d_negative));
    distances_labels = [d_normalized, labels];
    auxiliar = sortrows([distances_labels, labels],1);
    sorted_d_normalized = auxiliar(:,1);
    sorted_labels = auxiliar(:,2);
        
    subplot(2,1,2)
    plot(sorted_d_normalized,sorted_labels,'ok')
    xline(0.5, 'r');
    xlabel('Normalized d distance')
    ylabel('Label')
    title('Normalized distances related to the best threshold')
    
    sgtitle (['FEATURE: ',char(name_feature)])

end