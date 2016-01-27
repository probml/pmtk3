X = load('autompg.txt');
% remove rows with missing entries
M = any(isnan(X),2);
X(M,:) = [];
types = 'cdccccdd';
varNames = {'mpg', 'numCylinders', 'displacement', 'horsepower', 'weight', 'acceleration', 'year', ...
	    'origin'};
save('autompg.mat', 'X', 'varNames', 'types');

