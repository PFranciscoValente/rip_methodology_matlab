%%-----------------------------------------------------------------------
% File to create (train) artificial neural network (nn)
% author: Francisco Valente (paulo.francisco.valente@gmail.com)
%------------------------------------------------------------------------

function [net] = train_nn(inputs, outputs)

    % 1. define number of neurons in hidden layers
    net = patternnet([16 8]);
    
    % 2. define layers transfer functions
%     net.numLayers = 4;
%     net.layers{1}.transferFcn = 'tansig';
%     net.layers{2}.transferFcn = 'logsig';
    net.layers{3}.transferFcn = 'logsig'; % ultima camada logsig para fazer output no intervalo [0,1]

    % 3. define train parameters
    net.trainParam.epochs = 100;
%     net.trainParam.show = NaN;
    net.trainParam.goal = 1e-2;
    net.trainParam.lr = 0.001;
    net.performFcn = 'crossentropy';
%     net.trainParam.mu_max = 1000 ;
    net.trainFcn = 'trainscg';
    
    net.divideParam.trainRatio = 	80/100;
    net.divideParam.valRatio = 20/100;
%     net.divideParam.testRatio = 5/100;

    net.trainParam.showWindow = false;
    net.trainParam.showCommandLine = false;

    % 4. train neural network
    net = train(net,inputs,outputs);
    
end