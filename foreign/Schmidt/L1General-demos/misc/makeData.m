function [X,y] = makeData(type,nInstances,nVars,nClasses)

    X = 2*rand(nInstances,nVars)-1;
if strcmp(type,'regressionOutliers')
    X = rand(nInstances,nVars);
    w = randn(nVars,1)*5;
    y = X*w + randn(nInstances,1);
    outliers = rand(nInstances,1) > .75;
    y(outliers) = y(outliers) + rand(sum(outliers),1)*25;
elseif strcmp(type,'classificationNonlinear')
    nExamplePoints = 5; % Set to 1 for linear classifier, higher for more non-linear
    nClasses = 2;
    examplePoints = randn(nClasses*nExamplePoints,nVars);
    y = zeros(nInstances,1);
    for i = 1:nInstances
        dists = sum((repmat(X(i,:),nClasses*nExamplePoints,1) - examplePoints).^2,2);
        [minVal minInd] = min(dists);
        y(i,1) = sign(mod(minInd,nClasses)-.5);
    end
elseif strcmp(type,'multinomial')
    W = randn(nVars,nClasses);
    [junk y] = max(X*W,[],2);
elseif strcmp(type,'multinomialNonlinear')
    nExamplePoints = 3;
    examplePoints = randn(nClasses*nExamplePoints,nVars);
    y = zeros(nInstances,1);
    for i = 1:nInstances
        dists = sum((repmat(X(i,:),nClasses*nExamplePoints,1) - examplePoints).^2,2);
        [minVal minInd] = min(dists);
        y(i,1) = mod(minInd,nClasses)+1;
    end
elseif strcmp(type,'regressionNonlinear')
    X = 10*rand(nInstances,nVars)-5;
    nExamplePoints = 10;
    examplePoints = 10*rand(nExamplePoints,nVars)-5;
    exampleTarget = 10*rand(nExamplePoints,1)-5;
    y = zeros(nInstances,1);
    for i = 1:nInstances
        dists = sum((repmat(X(i,:),nExamplePoints,1) -examplePoints).^2,2);
        dists = sum(abs(repmat(X(i,:),nExamplePoints,1) - examplePoints),2);
        lik = (1/sqrt(2*pi))*exp(-dists/2);
        lik = lik./sum(lik);
        y(i,1) = lik'*exampleTarget + randn/15;
    end
elseif strcmp(type,'regressionNonlinear2')
    X = 10*rand(nInstances,nVars)-5;
    var = .1;
    nExamplePoints = 20;
    examplePoints = 10*rand(nExamplePoints,nVars)-5;
    exampleTarget = 10*rand(nExamplePoints,1)-5;
    y = zeros(nInstances,1);
    for i = 1:nInstances
        dists = sum((repmat(X(i,:),nExamplePoints,1) -examplePoints).^2,2);
        dists = sum(abs(repmat(X(i,:),nExamplePoints,1) - examplePoints),2);
        lik = (1/sqrt(2*pi))*exp(-dists/(2*var));
        lik = lik./sum(lik);
        y(i,1) = lik'*exampleTarget + randn/15;
    end
else
    w = randn(nVars,1);
    y = sign(X*w);
    if strcmp(type,'classificationFlip')
        flipPos = rand(nInstances,1) > .9;
        y(flipPos) = -y(flipPos);
    end
end