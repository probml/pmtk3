
rawdata = dlmread('heightWeightData.txt'); % comma delimited file
data.Y = rawdata(:,1); % 1=male, 2=female
data.X = [rawdata(:,2) rawdata(:,3)]; % height, weight

maleNdx = find(data.Y == 1);

X = data.X(maleNdx,:);
XS = standardize(X);
  
% Whiten
Sigma = cov(X);
mu = mean(X);
n = size(X,1);
[E,D] = eig(Sigma);
Wpca = sqrt(inv(D))*E';
Xt = X'; % each column is a case
XW = Wpca*(Xt-repmat(mu(:),1,n));
XWpca = XW'; % reach row is a case

Wzca = E * sqrt(inv(D)) *E';
XW = Wzca*(Xt-repmat(mu(:),1,n));
XWzca = XW'; % reach row is a case


% Plot data
XX = {X, XS, XWpca, XWzca};
ttl = {'raw', 'standarized', 'PCA whitened', 'ZCA whitened'};
figure
for j=1:length(XX)
  X = XX{j};
  % plot identity of each male
  subplot(2,2,j)
  N = size(X,1);
  for i=1:N
    plot(X(i,1), X(i,2));
    hold on
    if i<5
        str = sprintf('%d', i);
        text(X(i,1), X(i,2), str);
    end
  end
  hold on
  mu = mean(X); Sigma = cov(X);
  gaussPlot2d(mu, Sigma);
  if j>2, axis equal, end
  title(ttl{j});
end

printPmtkFigure('heightWeightWhitenZCA')
