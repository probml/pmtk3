function model = mixGaussCreate(mu, Sigma, mixWeight)

model.cpd.mu = mu;
model.cpd.Sigma = Sigma;
model.mixWeight = mixWeight;
model.nmix = numel(mixWeight);
model.type = 'mixGauss';
end
