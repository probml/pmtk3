
data = load('housing.data');

% make X and y matrices
[n,d] = size(data);
X = data(:, 1:d-1);
y = data(:,d);   

% standardize feature values and center target
mu_y = mean(y);
y = y - mu_y;
[X, mu, sigma] = standardizeCols(X);