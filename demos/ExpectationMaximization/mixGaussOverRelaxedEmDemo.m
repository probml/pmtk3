%% Demo of over-relaxed EM for fitting Gaussian mixture model
% We use  data sampled from a GMM

%PMTKauthor  Krishna Nand Keshava Murthy

ntrials = 2;
for trial = 1:ntrials
  setSeed(trial);
  
  D = 15; N = 5000;
  Clusters = 10;
  mu = rand(D,Clusters); mixweight = normalize(rand(1,Clusters));
  Sigma = zeros(D,D,Clusters);
  for k=1:Clusters
    Sigma(:,:,k) = randpd(D);
  end
  trueModel = struct('K', Clusters, 'mu', mu, 'Sigma', Sigma, 'mixweight', mixweight);
  [fullData] = mixGaussSample(trueModel, N);
  
  Ks = [5 10];
  verbose = true;
  eta = {[], 1, 1.25, 2, 5}; % over-relaxation increase factor
  nmethods = length(eta);
  llHist  = cell(1, nmethods);
  models = cell(1, nmethods);
  names = {'EM', 'OR(1)', 'OR(1.25)', 'OR(2)', 'OR(5)'};
  [styles, colors, symbols] =  plotColors();
  for k = 1:length(Ks)
    K = Ks(k);
    [mu,Sigma,mixweight] = kmeansInitMixGauss(fullData, K);
    for m=1:nmethods
    tic
    [models{m}, llHist{m}] = mixGaussFitEm(fullData, K, ...
      'Sigma', Sigma, 'mu', mu, 'mixweight', mixweight, ...
      'overRelaxFactor',eta{m}, 'verbose', verbose, 'doMAP', 1);
    tim(m) = toc;
    end
    
    figure
    hold on
    for m=1:nmethods
      str= sprintf('%s%s%s', colors(m), symbols(m), styles{m});
      plot(llHist{m}, str, 'LineWidth',2,'MarkerSize',10)
      legendStr{m} = sprintf('%s (%5.3f)', names{m}, tim(m));
    end
    legend(legendStr, 'location', 'southeast');
    xlabel('iterations'); ylabel('loglik')
    title(sprintf('K=%d, D=%d, N=%d', K, D, N));
  end
end
