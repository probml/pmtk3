
% Z -> Xj -> Yj
% Z is mixture node
% Xj is binary tag
% Yj is response of tag detector

% We generate some synthetic correlated binary data
% consisting of 10s and 01s

setSeed(0);
D = 4; % num bits
mixWeights = normalize(ones(1,D));
N = 20;
X1 = repmat([1 0 0 1], N, 1);
X2 = repmat([0 1 1 0], N, 1);
X = [X1; X2];
X = X+1; 

options = {'maxIter', 10, 'verbose', true};
[model, loglikHist] = mixModelFit(X, 2, 'discrete', options{:});

%{
This works as expected: in cluster 1,
the first feature (col 1) is most likely 1,
the second feature (col 2) is most likely 0
etc

> squeeze(model.cpd.T(1,:,:))
ans =
    0.0455    0.9545    0.9545    0.0455
    0.9545    0.0455    0.0455    0.9545



and vice versa for cluster 2

squeeze(model.cpd.T(2,:,:))
ans =
    0.9545    0.0455    0.0455    0.9545
    0.0455    0.9545    0.9545    0.0455

%}

% Now generate noisy function of X

% mu(c,j) 
% Make off bits be -ve, on bits be +ve
mu = [-1 -2 -3 -4;
       1  2  3  4];
sigma = 1;
Y = zeros(N, D);
for i=1:N
  for j=1:D
  end
end