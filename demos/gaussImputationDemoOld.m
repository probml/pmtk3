%% Gauss Imputation Demo
%
%%

% This file is from pmtk3.googlecode.com

function gaussImputationDemoOld()

setSeed(0);
d = 10;
mu = randn(d,1); Sigma = randpd(d);
pcMissing = 0.5;

% Training data is larger than test data, and is missing data at random
[XfullTrain, XmissTrain] = mkData(mu, Sigma, 100, true, pcMissing);

% Test data omits 'stripe' rather than at random, for easier visualization
[Xfull, Xmiss, Xhid] = mkData(mu, Sigma, 12, false, pcMissing);

% we either train on fully observed data (useFull) or partially observed
for useFull = [true]
    if useFull
        model = gaussMissingFitEm(XfullTrain, 'verbose', false);
        muHat = model.mu;
        SigmaHat = model.Sigma;
        
        assert(approxeq(rowvec(muHat), mean(XfullTrain)))
        assert(approxeq(SigmaHat, cov(XfullTrain,1)))
        [Ximpute, V] = gaussImpute(model, Xmiss);
        
        Xtrain = XfullTrain;
        fname = 'mvnImputeFull';
    else
        [model, LLtrace] = gaussMissingFitEm(XmissTrain, 'verbose', false);
        figure; plot(LLtrace); title('EM loglik vs iteration')
        [Ximpute, V] = gaussImpute(model, Xmiss);
        Xtrain = XmissTrain;
        fname = 'mvnImputeEm';
    end
    conf = 1./V;
    conf(isinf(conf))=0;
    
    figure;
    hintonScaleMulti({Xtrain}, {'map', 'jet', 'title', 'training data'}, ...
        {Xmiss}, {'map', 'Jet', 'title', 'observed'}, ...
        {Ximpute, conf}, {'title', 'imputed'}, ...
        {Xhid}, {'title', 'hidden truth'});
    printPmtkFigure(fname);
end

end


function [Xfull, Xmiss, Xhid, missing] = mkData(mu, Sigma, n, rnd, pcMissing)



d = length(mu);
model = struct('mu', mu, 'Sigma', Sigma);
Xfull = gaussSample(model, n);

if rnd
    % Random missing pattern
    missing = rand(n,d) < pcMissing;
else
    % Make the first pc% stripes (features) be completely missing
    missing = false(n,d);
    missing(:, 1:floor(pcMissing*d)) = true;
end

Xmiss = Xfull;
Xmiss(missing) = NaN;
Xhid = Xfull;
Xhid(~missing) = NaN;

end
