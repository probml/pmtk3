% Boston housing data from UCI repository
data = load('housing.txt');     
X = data(:, 1:13); % feature 4 is binary (1 = close to charles river, 0 otherwise)
y = data(:,14);                   % cts
[n d] = size(X);
seed = 0; rand('state', seed);
perm = randperm(n);
X = X(perm,:);
y = y(perm);

istrain = [ones(1,300) zeros(1,n-300)];
% see housing.names for a fuller description
names = {'crimeRate', 'zoned', 'industrial', 'charles', 'nox', 'rooms', ...
	 'age', 'distances', 'radial', 'tax', 'pupilTeacher', 'black',...
	 'lowerStat', 'medianValue'};

Xtrain = X(find(istrain),:);
ytrain = y(find(istrain),:);
Xtest = X(find(~istrain),:);
ytest = y(find(~istrain),:);

save('housing.mat', 'Xtrain', 'ytrain', 'Xtest', 'ytest', 'X','y', 'names','istrain');
