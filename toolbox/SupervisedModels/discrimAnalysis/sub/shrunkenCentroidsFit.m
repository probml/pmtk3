

function model = shrunkenCentroidsFit(model, Xtrain, ytrain, lambda)
%author Robert Tseng

C = length(unique(ytrain));
[N, D] = size(Xtrain);
Nclass = zeros(1,C);

% compute pooled standard deviation
xbar = mean(Xtrain);
sse= zeros(1,D);
for c=1:C
    ndx = find(ytrain==c);
    Nclass(c) = length(ndx);
    % if there may be no examples of any given class, use generic mean
    if Nclass(c)==0
        centroid = xbar;
    else
        centroid = mean(Xtrain(ndx,:));
    end
    sse = sse + sum( (Xtrain(ndx,:) - repmat(centroid, [Nclass(c) 1])).^2);
end
sigma = sqrt(sse ./ (N-C));
s0 = median(sigma);

mu = model.mu;
m = zeros(1,C);
offset = zeros(C,D);
for c=1:C
    if Nclass(c)==0
        m(c) = 0;
    else
        % Hastie below eqn 18.4
        m(c) = sqrt(1/(Nclass(c) - 1/N));
    end
    % Hastie eqn 18.4
    offset(c,:) = (mu(:,c)' - xbar) ./ (m(c) * (sigma+s0));
    % Hastie eqn 18.5
    offset(c,:) = softThreshold(offset(c,:), lambda);
    % Hastie eqn 18.7
    mu(:,c) = (xbar + m(c)* (sigma+s0) .* offset(c,:))';
end


model.mu = mu;
model.SigmaPooledDiag = sigma(:).^2;

% for visualization purposes, we keep this:
model.shrunkenCentroids = offset; % m_cj
end
