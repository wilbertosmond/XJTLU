% clear, close all, format compact, clc
clear, close all, clc; 

%% Step 1. Data pre-processing: Prepare input and output
% Prepare inputs & outputs for network training
% load input and target data
load logo.mat;
% define inputs
X = [eohsamples(:,1:64)]; % inputs = eohsamples matrix after removing null features #65-#80
X = normalize(X); % normalize features data
% define targets
T = [eohlabels]; % targets = eohlabels vector

% Split input data into 80% training and 20% testing
% cross validation (train: 80%, test: 20%)
cv = cvpartition(size(X,1),'HoldOut',0.2);
idx = cv.test;
% separate to training and test data
Xtrain = X(~idx,:);
Xtest = X(idx,:);
% separate to training and test targets
Ttrain = T(~idx,:);
Ttest = T(idx,:);

%% Step 2. Create and train a radial-basis function network (RBFN)
%% Step 2.1. First training phase: Select RBF centers and variances
% Find RBF centers by K-means clustering
[idx, centers, SUMD, D] = kmeans(Xtrain,10); % inputs data and number of centers; returns idx, cluster centroid locations, within-cluster sums of point-to-centroid distances, distances from each point to every centroid
nOfCenters = size(centers,1); % set number of centers

% Set variances of training data for each RBF neuron
nOfPoints = size(Xtrain,1); % set number of data points
variances = sum(D.^2)/size(Xtrain,1); % compute variances

% Train RBFN
PHItrain = kernelmat(Xtrain,centers,variances); % compute kernel matrix for training from own-made kernelmat() function

%% Step 2.2. Second training phase: Train output weights using pseudo-inverse
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Cited from: $Author: ChrisMcCormick $    $Date: 2014/08/18 22:00:00 $    $Revision: 1.3 $

% Train output weights
% create a matrix to hold all of the output weights
W = zeros(nOfCenters + 1, size(unique(Ttrain),1));
% for each target category
for (c = 1 : size(unique(Ttrain),1))
    % Make the y values binary -- 1 for category 'c' and 0 for all other categories.
    y_c = (Ttrain == c);
    % Use the normal equations to solve for optimal theta.
    W(:, c) = pinv(PHItrain' * PHItrain) * PHItrain' * y_c;
end
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

%% Step 3. Evaluate the RBFN's accuracy on testing set
% Test RBFN
PHItest = kernelmat(Xtest,centers, variances); % compute kernel matrix for testing from own-made kernelmat() function

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Cited from: $Author: ChrisMcCormick $    $Date: 2014/08/18 22:00:00 $    $Revision: 1.3 $

% create a vector to hold all of the test outputs
Ytest = zeros(1,size(Xtest,1));
% for each sample
for (i = 1 : size(Xtest,1))
    % Compute the scores for each category.
    scores = W' * PHItest(i,:)';
	[maxScore, category] = max(scores);
    % Validate the result.
    Ytest(1,i) = category;
end
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

% Create confusion matrix with targets and rounded outputs
C = confusionmat(Ttest,Ytest) % confusion matrix

% Compute accuracy
Accuracy = sum(diag(C))/length(Ttest) % sum the diagonal elements of confusion matrix C and divide it with total number of samples 

%%% --------------------------------------------------------------------
%%% Optional: Compute MSE for training process
%%% --------------------------------------------------------------------

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Cited from: $Author: ChrisMcCormick $    $Date: 2014/08/18 22:00:00 $    $Revision: 1.3 $

% Create a vector to hold all of the test outputs
Ytrain = zeros(1,size(Xtrain,1));
% for each sample
for (i = 1 : size(Xtrain,1))
    % Compute the scores for each category.
    scores = W' * PHItrain(i,:)';
	[maxScore, category] = max(scores);
    % Validate the result.
    Ytrain(1,i) = category;
end
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

% Compute mean squared error
MSEtrain = immse(Ttrain',Ytrain) 