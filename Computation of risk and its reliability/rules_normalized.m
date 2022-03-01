%------------------------------------------------------------------------
% File to compute individual decision rule using the normalized distance approach
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
% 2020
%------------------------------------------------------------------------


function [centroid_negative, centroid_positive, original_threshold, feat_outputs, geom_mean, sens, spec] = rules_normalized(data, labels)

    %% CREATE THE DECISION RULE
    
    % 1. divide data into positive (die) and negative (survived)
    
    idx_negative = find(labels==0);
    idx_positive = find(labels==1);
    
    feat_negative = data(idx_negative);  % positive data
    feat_positive = data(idx_positive); % negative data
        
    negative_nr = length(idx_negative);
    positive_nr = length(idx_positive);
    
    
    % 2. compute negative and positive centroids
    % se considerarmos que as variaveis não sao muito skewed então poderemos utilizar a média euclideana,
    % caso contrario devemos utilizar a mediana
    % para regras que utilizam apenas uma feature, kmeans com distancia euclideana é a mesma coisa que média euclideana
    % e mediana podera ser obtida usando kmeans com distancia 'cityblock'

    % 2.1 se considerarmos que podemos usar sempre media
    if 1 % se quiseremos usar a segunda opção, pôr "if 0"
        
        [~,centroid_negative] = kmeans(feat_negative, 1); % centroid classe negativa
        [~,centroid_positive] = kmeans(feat_positive, 1); % centroid classe positiva
    
    % 2.2 se considerarmos que temos de usar media ou mediana dependendo dos dados
    else
        
        % nesta caso vamos priveiro ver se a variavel segue distribuição
        % normal ou nao (usando os testes lilliefors e shapiro-wilk), e se
        % seguir usamos media (kmeans-euclidean), se nao seguir usamos
        % mediana (kmeans-cityblock)
        
        alpha = 0.01;
        
        % teste de normalidade considerando os valores todos
        [h_lf,p_lf] = lillietest(data,'Alpha',alpha);
        [h_sw, p_sw,~] = swtest(data, alpha);
        % hist(data)

        % teste de normalidade considerando os valores negativos
        [h_lf,p_lf] = lillietest(feat_negative,'Alpha',alpha);
        [h_sw_neg, p_sw,~] = swtest(feat_negative, alpha);
        % hist(feat_negative)

        % teste de normalidade considerando os valores positivos
        [h_lf,p_lf] = lillietest(feat_positive,'Alpha',alpha);
        [h_sw_pos, p_sw,~] = swtest(feat_positive, alpha);
        % hist(feat_positive)
        
        unique_values = unique(data);
        unique_values = unique_values(~isnan(unique_values));


        % 2.2.1 se seguir distribuição normal segundo o teste de shapiro-wilk
        % aplicar distancia euclideana, caso contrario a distancia cityblock
        % centroid negativo
        if h_sw_neg==0
            [~,centroid_negative] = kmeans(feat_negative, 1);
        else
            [~,centroid_negative] = kmeans(feat_negative, 1, 'Distance', 'cityblock');
        end

        % centroid positivo
        if h_sw_pos==0
            [~,centroid_positive] = kmeans(feat_positive, 1);
        else
            [~,centroid_positive] = kmeans(feat_positive, 1, 'Distance', 'cityblock');
        end
    end

    % 3. compute, for each patient, the euclidean distance between his/her
    % value of the feature being evaluated and the corrsponding
    % centroid, for both positive and negative classes

    d_negative = dist(data, centroid_negative, 2);
    d_positive = dist(data, centroid_positive, 2);

    % 4. compute the normalized distance of the patient to the centroids
    d_normalized = 1 - (d_positive./(d_positive+d_negative));

    % 5. compute the output given by the rule for each patient   
    threshold  = 0.5; % threshold of normalized distance: 0.5 (mean of centroids)
    original_threshold = mean([centroid_negative,centroid_positive]);
    feat_outputs = d_normalized >= threshold;

    %% COMPUTE SOME METRICS ABOUT THE CREATED RULE

    % sort labels according to normalized distances
    distances_labels = [d_normalized, labels];
    auxiliar = sortrows([distances_labels, labels],1);
    sorted_d_normalized = auxiliar(:,1);
    sorted_labels = auxiliar(:,2);

    % true negatives and positives
    lower_than_threshold = find(sorted_d_normalized<threshold);
    higher_than_threshold = find(sorted_d_normalized>threshold);
    true_negative = length(find(sorted_labels(lower_than_threshold)==0));
    true_positive = length(find(sorted_labels(higher_than_threshold)==1));

    % metrics evaluation
    sens = true_negative/negative_nr;
    spec = true_positive/positive_nr;
    geom_mean = sqrt(sens*spec); % individual geometric mean of the rule

end