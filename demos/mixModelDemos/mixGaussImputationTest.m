%% Simple test of mixGaussMissingFitEM
setSeed(0);
nmix = 5;
d = 2;
model.mu = 10*randn(d, nmix);
Sigma = zeros(d, d, nmix);
for c=1:nmix
   Sigma(:,:,c) = randpd(d) + 0.1*eye(d); 
end
model.Sigma = Sigma;
model.mixweight = normalize(rand(1, nmix) + ones(1, nmix)); 
nsamples = 30;
X = mixGaussSample(model, nsamples);
Xmissing = X;
Xmissing(1:7:end) = NaN;
%%
prior.m0     = zeros(d,1);
prior.kappa0 = 0;
prior.nu0    = d+2;
prior.S0     = eye(d);
model = mixGaussFitEmMissingData(Xmissing, nmix, 'prior', prior);

%modelMissing = mixGaussMissingFitEm(Xmissing, nmix);
modelNotMissing = mixGaussFitEm(X, nmix, 'doMAP', true);
