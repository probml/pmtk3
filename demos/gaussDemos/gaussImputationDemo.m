function gaussImputationDemo()


setSeed(1);
d = 10;
mu = randn(d,1); Sigma = randpd(d);
pcMissing = 0.3;

% Training data is larger than test data, and is missing data at random
[XfullTrain, XmissTrain] = mkData(mu, Sigma, 100, true, pcMissing);

% Test data omits 'stripe' rather than at random, for easier visualization
[Xfull, Xmiss, Xhid] = mkData(mu, Sigma, 5, false, pcMissing);


[model, LLtrace] = gaussMissingFitEm(XmissTrain, 'verbose', false);
[XimputeEM, V] = gaussImpute(model, Xmiss);
conf = 1./V;
conf(isinf(conf))=0;
confEM = conf;

trueModel = struct('mu', mu, 'Sigma', Sigma);
[XimputeTruth, V] = gaussImpute(trueModel, Xmiss);
conf = 1./V;
conf(isinf(conf))=0;
confTruth = conf;
  

hintonScaleMulti( ...
   {Xmiss}, {'-map', 'Jet', '-title', 'observed'}, ...
   {Xhid}, {'-title', 'hidden truth'}, ...
   {XimputeTruth, confTruth}, {'-title', sprintf('imputed using true params')}, ...
   {XimputeEM, confEM}, {'-title', sprintf('imputed using estimated params')} ...
   );

figure(2); printPmtkFigure('mvnImputeObs');
figure(3); printPmtkFigure('mvnImputeHid');
figure(4); printPmtkFigure('mvnImputeImputeTruth');
figure(5); printPmtkFigure('mvnImputeImputeEM');

figure; imagesc(cov2cor(Sigma)); colorbar

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