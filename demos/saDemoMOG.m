function SAdemoMOG()
% Demo of Simulated Annealing for finding the mode of
% a mixture of two 1D Gaussians using a Gaussian proposal.


sigma_prop = 10;                 % Standard deviation of the Gaussian proposal.

seed = 1; randn('state', seed); rand('state', seed);
xinit = 20*rand(1,1); % initial state
Nsamples  = 5000;
opts = struct(...
    'proposal', @(x) (x+sigma_prop*randn(1,1)), ...
    'maxIter', Nsamples, ...
    'minIter', Nsamples, ...
    'temp', @(T,iter) (0.995*T), ...
    'verbose', 0);

[xopt, fval, samples, energies, acceptRate] =  SA(@target, xinit, opts);
xopt
fval

% plot the histogram of samples
N_bins = 50; 
Nsamples = size(samples, 1)
Ns = round(linspace(100, Nsamples, 4));
figure;
for i=1:4
  subplot(2,2,i)
  x_t = linspace(-10,20,1000);
  y_t = exp(-feval(@target, x_t)); % prob = exp(-energy)
  [b,a] = hist(samples(1:Ns(i)), N_bins);
  measure = a(2)-a(1); % bin width.
  area = sum(b*measure);
  bar(a,b/(area),'y')
  hold on;
  plot(x_t,y_t,'k','linewidth',2)
  axis([-10 20 0 .15])
  text(14,.1,sprintf('iter %d', Ns(i)))
end

%%%%%%%%%%

function p = mogProb(x)

mixWeights = [0.3 0.7];
mu = [0 10];
sigma = [2 2];

% p(n) = sum_k w(k) N(x(n)|mu(k), sigma(k))
K = length(mixWeights);
N = length(x);
p = zeros(N,1);
for k=1:K
  p = p + mixWeights(k)*mvnpdf(x(:), mu(k), sigma(k));
end

function  E = target(x)
p = mogProb(x);
E = -log(p+eps); % energy = -ve log posterior

