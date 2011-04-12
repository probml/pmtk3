

[W,b,proto] = tippingDemo();

setSeed(1);
[L p]= size(W); % L is size of latent space
src = [1 2 3 1];
Ntest = length(src);
% each example is a ROW vector

% This file is from pmtk3.googlecode.com


dataTestNoisy = zeros(Ntest, p);
dataTestClean = zeros(Ntest, p);
dataTestMissing = zeros(Ntest, p);
for n=1:Ntest
  dataTestClean(n,:) = proto(:,src(n))';
  noise = rand(p,1) < 0.05;
  dataTestNoisy(n,:) = dataTestClean(n,:);
  dataTestNoisy(n,noise) = 1-dataTestNoisy(n,noise); % flip bits
  missing = rand(p,1) < 0.5;
  dataTestMissing(n,:) = dataTestNoisy(n,:);
  dataTestMissing(n,missing) = NaN;
end

yhat = zeros(Ntest, p);
postPred = zeros(Ntest, p);
logprob = zeros(Ntest,1);
hammingErr = zeros(Ntest, 1);
for n=1:Ntest
  y = dataTestMissing(n,:);
  [yhat(n,:), postPred(n,:), loglikV] = imputeBinaryVectorPCA(y, W, b);
  % Compute p(h|v) where v is like action, h is like response
  yFullObs = dataTestNoisy(n,:);
  [muPost, SigmaPost, lambda, loglikHV] = varInferLogisticGaussCanonical(yFullObs, W, b);
  logprob(n) = loglikHV - loglikV;
  hammingErr(n) = sum(yhat(n,:) ~= yFullObs);
end
logprob
hammingErr

figure; image_rgb(dataTestNoisy+1); colorbar; title('observed noisy');
Y = dataTestMissing+1; Y(isnan(Y))=3;
figure;image_rgb(Y); colorbar; title('observed missing');
figure; imagesc(postPred); colorbar; title('postpred');
figure; image_rgb(yhat+1); colorbar; title('map')

