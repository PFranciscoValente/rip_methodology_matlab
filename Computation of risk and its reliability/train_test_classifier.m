%%-----------------------------------------------------------------------
% File to create (train) prediction models and apply (test) them
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [clf_train_outputs, clf_test_outputs, rem_outputs] = ...
    train_test_classifier(feat_train,feat_test,label_train, method, type, rem_negative_data)
    
    % NOTA: label_train for the method 'rules' is equivalent to the matrix rules_acceptance
    
    % classifiers (clf)
    % nn : artificial neural network
    % svm : support vector machine
    % dt : decision tree
    % et : ensemble of tree
    % lr : logistic regression
    % slr : stepwise logistic regression
    % knn : k nearest neighbor
    % lda : linear discriminant analysis
    % qda : quadratic discriminant analysis
    % lasso : least absolute shrinkage and selection operator

    %% DEVELOPED APPROACH BASED ON PERSONALIZATION OF THE DECISION SET
    
    if isequal(type,'rules')
        
        % TRAINING

        clf_train_outputs = [];
        rem_outputs = [];

        for i=1:size(label_train,2)
            
            if isequal(method,'nn')
                clf = train_nn(feat_train',label_train(:,i)');
                output = sim(clf, feat_train')';
                if isempty(rem_negative_data)
                    output2 = [];
                else
                    output2 = sim(clf, rem_negative_data')';
                end

            else
                if isequal(method,'svm')
                    clf = fitcsvm(feat_train,label_train(:,i),'KernelFunction','rbf','ClassNames',[0,1]);

                elseif isequal(method,'dt')
                    MinLeafSize = 1;
                    clf = fitctree(feat_train,label_train(:,i),...
                        'MinLeafSize',MinLeafSize);

                elseif isequal(method,'et')
                    num_trees = 6;
                    treeStump = templateTree('MinLeafSize',3);
                    clf = fitcensemble(feat_train,label_train(:,i),'Method','AdaBoostM1','NumLearningCycles',num_trees,'Learners',treeStump);

                elseif isequal(method,'lr')
                    clf = fitglm(feat_train,label_train(:,i),'Distribution','binomial');
                    
                elseif isequal(method,'slr')
                    clf =stepwiseglm(feat_train,label_train(:,i),'constant', 'Upper','linear','Distribution','binomial');

                elseif isequal(method,'knn')
                    num_neighbors = 3;
                    clf = fitcknn(feat_train,label_train(:,i),'NumNeighbors',num_neighbors);
                    
                elseif isequal(method,'lda')
                    clf = fitcdiscr(feat_train,label_train(:,i),'Prior','uniform');
                
                elseif isequal(method,'qda')
                    clf = fitcdiscr(feat_train,label_train(:,i),'DiscrimType','diagquadratic');
                
                elseif isequal(method,'lasso') % is not beeing used
                    [B,FitInfo] = lassoglm(feat_train,label_train(:,i),'binomial','CV',3);
                    idxLambdaMinDeviance = FitInfo.IndexMinDeviance;
                    B0 = FitInfo.Intercept(idxLambdaMinDeviance);
                    % here, clf does not correspond to a classifier but to
                    % coefficients, but due to a practical issue, it was
                    % represented as clf
                    clf = [B0; B(:,idxLambdaMinDeviance)];

                end
                
                if isequal(method,'lasso') % is not beeing used
                    output = glmval(clf,feat_train,'logit');
                else
                    output = predict(clf, feat_train);
                    if isempty(rem_negative_data)
                        output2 = [];
                    else
                        output2 = predict(clf, rem_negative_data);
                    end
                end
            end

            clf_train_outputs = [clf_train_outputs, output];
%             rem_outputs = [rem_outputs, []];
            rem_outputs = [rem_outputs, output2];
            models{i} = clf;

        end

        % TESTING

        clf_test_outputs = [];

        for i=1:size(label_train,2)

            trained_clf = models{i};
            if isequal(method,'nn')
                output = sim(trained_clf, feat_test')';
            elseif isequal(method,'lasso')
                output = glmval(clf,feat_test,'logit');
            else
                output = predict(trained_clf, feat_test);
            end
            clf_test_outputs = [clf_test_outputs, output];

        end

        
    %% STANDARD MACHINE LEARNING APPROACH
    
    elseif isequal(type,'standard')
    
        % TRAINING
        
        if isequal(method,'nn')
            clf = train_nn(feat_train',label_train');
            output = sim(clf, feat_train')';

        else
            if isequal(method,'svm')
                clf = fitcsvm(feat_train,label_train,'KernelFunction','linear','ClassNames',[0,1]);

            elseif isequal(method,'dt')
                clf = fitctree(feat_train,label_train, 'MaxNumSplits',6);

            elseif isequal(method,'et')
%                 num_trees = 20;
%                 treeStump = templateTree('MaxNumSplits',10,'MinLeafSize',1);
%                 clf = fitcensemble(feat_train,label_train,'Method','AdaBoostM1','NumLearningCycles',num_trees,'Learners',treeStump);
                clf = TreeBagger(20, feat_train, label_train, ...
            'PredictorNames', [], 'OOBPrediction', 'on',  ...
            'Method','classification', 'MaxNumSplits', 6, 'MinLeafSize', [],...
            'CategoricalPredictors', []);
        
            elseif isequal(method,'lr')
                clf = fitglm(feat_train,label_train,'Distribution','binomial');

            elseif isequal(method,'knn')
                num_neighbors = 7;
                clf = fitcknn(feat_train,label_train,'NumNeighbors',num_neighbors);
            
            elseif isequal(method,'lda')
                clf = fitcdiscr(feat_train,label_train);
                
            elseif isequal(method,'qda')
                clf = fitcdiscr(feat_train,label_train,'DiscrimType','pseudoquadratic');

            end
            
            if isequal(method,'dt')
            	
                [label,score,node,cnum] = predict(clf, feat_train);
                output =score(:,2);
            
            else
                output = predict(clf, feat_train);
            end
        end

        clf_train_outputs = output;

        % TESTING

        trained_clf = clf;
        clf_test_outputs = [];

        if isequal(method,'nn')
            output = sim(trained_clf, feat_test')';
        elseif isequal(method,'dt')
            [label,score,node,cnum] = predict(trained_clf, feat_test);
            output =score(:,2)
        else
            output = predict(trained_clf, feat_test);
        end
        clf_test_outputs = output;
        
    end  
end
