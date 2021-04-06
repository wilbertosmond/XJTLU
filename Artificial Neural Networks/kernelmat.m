function [PHI] = kernelmat1(X,centers,variances)

nOfPoints = size(X,1); % set number of data points
nOfCenters = size(centers,1); % set number of centers

% Compute kernel matrix 
for i = 1:nOfPoints
    for j = 1:nOfCenters
        PHI(i,j) = exp((-norm(X(i,:)-centers(j,:))^2)/(2*variances(j)));
    end
end

% Add a column of 1s for the bias term.
PHI = [ones(nOfPoints, 1), PHI];