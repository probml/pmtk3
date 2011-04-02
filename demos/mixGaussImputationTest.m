%% Simple test of mixGaussMissingFitEM

% This file is from pmtk3.googlecode.com

setSeed(1);
nmix = 5;
d = 2;
model.mu = 10*randn(d, nmix);
Sigma = zeros(d, d, nmix);
for c=1:nmix
   Sigma(:,:,c) = randpd(d) + 0.1*eye(d); 
end
model.Sigma = Sigma;
model.mixweight = normalize(rand(1, nmix) + ones(1, nmix)); 
nsamples = 100;
X = mixGaussSample(model.mu, model.Sigma, model.mixweight, nsamples);
Xmissing = X;
Xmissing(1:7:end) = NaN;
%%

model = mixGaussMissingFitEm(Xmissing, nmix, 'doMap', true, 'verbose', true);
figure; hold on;
plot(X(:, 1), X(:, 2), '.');
for i=1:nmix
   plot(model.cpd.mu(1, i), model.cpd.mu(2, i), '+', 'markersize', 10, 'color', 'r') 
end


% If data is fully observed should get same results
% as standard EM, provided we initialise in the same way
setSeed(0);
modelMissing = mixGaussMissingFitEm(X, nmix);
modelMissing.cpd.mu

setSeed(0)
modelNotMissing = mixGaussFit(X, nmix);
modelNotMissing.cpd.mu