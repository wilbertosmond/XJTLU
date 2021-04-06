% clear, close all, format compact, clc
clear, close all, clc; 

%% Step 1. Data pre-processing: Prepare input and output
% Prepare inputs & outputs
% load input and target data
load logo.mat;
% define inputs
X = [eohsamples(:,1:64)]; % inputs = eohsamples matrix after removing null features #65-#80
X = normalize(X); % normalize features data
% define targets
T = [eohlabels]; % targets = eohlabels vector

% Split both input and target data into 80% training and 20% testing
% cross validation (train: 80%, test: 20%)
cv = cvpartition(size(X,1),'HoldOut',0.2);
idx = cv.test;
% separate to training and test data
Xtrain = X(~idx,:);
Xtest = X(idx,:);
% separate to training and test targets
Ttrain = T(~idx,:);
Ttest = T(idx,:);

%% Step 2. Create and train a multilayer perceptron (MLP)
% Create an MLP architecture
net = feedforwardnet(30,'traingdm'); % one hidden layer of 30 hidden neurons

% Adjust parameters of the MLP
net.trainParam.lr = 0.01; % learning rate = 0.01
net.trainParam.mc = 0.05; % set momentum = 0.05

% Train the neural network
[net,tr] = train(net,Xtrain',Ttrain'); % return net, training record and output

%% Step 3. Evaluate the performance of the neural network
% Simulate the neural network with test data
Ytest = sim(net,Xtest.');

% Create confusion matrix
% round output values to {1,2,3,4,5} as target values
Ytest(Ytest<1) = [1]; % assign output values below 1 to 1
Ytest(Ytest>5) = [5]; % assign output values below 5 to 5
Yrounded = round(Ytest); % round everything else to the nearest integer
% create a confusion matrix with targets and rounded outputs
C = confusionmat(Ttest.',Yrounded) % confusion matrix
%CC = confusionchart(T,Yrounded); % chart of confusion matrix

% Compute accuracy
Accuracy = sum(diag(C))/length(Ttest) % sum the diagonal elements of confusion matrix C and divide it with total number of samples 