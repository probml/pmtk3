%% Gauss Imputation Demo using ICM
%
%%

% This file is from pmtk3.googlecode.com

function gaussImputationICMDemo()

setSeed(0);
d = 10;
mu = randn(d,1); Sigma = randpd(d);

% Training data is larger than test data, and is missing data at random
[XfullTrain, XmissTrain] = mkData(mu, Sigma, 100, true);

% Test data omits 'stripe' rather than at random, for easier visualization
[Xfull, Xmiss, Xhid] = mkData(mu, Sigma, 10, false);

verb = true;
%for useFull = [true false]
for useFull = false
    if useFull
        modelHat = gaussMissingFitICM(XfullTrain, 'verbose', verb);
        [Ximpute, V] = gaussImpute(modelHat, Xmiss);
        Xtrain = XfullTrain;
        fname = 'mvnImputeFull';
    else
        [modelHat, LLtrace] = gaussMissingFitICM(XmissTrain, 'verbose', verb);
        figure; plot(LLtrace); title('EM loglik vs iteration')
        [Ximpute, V] = gaussImpute(modelHat, Xmiss);
        Xtrain = XmissTrain;
        fname = 'mvnImputeEm';
    end
    conf = 1./V;
    conf(isinf(conf))=0;
    
    figure;
    hintonScale({Xtrain}, {'map', 'jet', 'title', 'training data'}, ...
        {Xmiss}, {'map', 'Jet', 'title', 'observed'}, ...
        {Ximpute, conf}, {'title', 'imputed'}, ...
        {Xhid}, {'title', 'hidden truth'});
    printPmtkFigure(fname);
end

end


function [Xfull, Xmiss, Xhid, missing] = mkData(mu, Sigma, n, rnd)


pcMissing = 0.5;
d = length(mu);
model = struct('mu', mu, 'Sigma', Sigma);
Xfull = gaussSample(model, n);

if rnd
    % Random missing pattern
    missing = rand(n,d) < pcMissing;
else
    % Make the first 3 stripes (features) be completely missing
    missing = false(n,d);
    missing(:, 1:floor(pcMissing*d)) = true;
end

Xmiss = Xfull;
Xmiss(missing) = NaN;
Xhid = Xfull;
Xhid(~missing) = NaN;

end
