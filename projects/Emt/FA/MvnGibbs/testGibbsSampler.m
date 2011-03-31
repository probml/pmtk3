  % implementation of Peter Hoff's book chapter on Multivariate Analysis
  % pimaMiss doesn't work right now.
  clear all
  dataset = 'readingComprehension';

  % select dataset
  switch dataset
    case {'pimaFull','pimaMiss'} 
      switch dataset
        case 'pimaFull'
          [sn glu bp skin bmi] = textread('pimaFull.txt','%d %d %d %d %f','headerlines',1);
          data = [glu bp skin bmi]';
        case 'pimaMiss'
          [sn glu bp skin bmi] = textread('pimaMiss.txt','%d %d %d %d %f','headerlines',1);
          data = [glu bp skin bmi]';
          missData = find((data == -1000));
          data(missData) = NaN;
      end
      [d,n] = size(data);

      params.mean0 = [120 64 26 26]';
      sd0 = params.mean0/2;
      W = (1-eye(d)).*(0.1*ones(d,d)) + eye(d);
      params.covMat0 = W.*(sd0*sd0');
      params.nu0 = d +2;
      params.S0 = params.covMat0;

    case 'readingComprehension'
      scores = textread('readingComprehensionHoff.txt');
      data = scores';
      params.mean0 = [50 50]';
      params.covMat0 = [625 312.5; 312.5 625];
      params.nu0 = 4;
      params.S0 = params.covMat0;

    case 'sim'
      setSeed(1)
      params.mean0 = [1 1]';
      params.covMat0 = [1 0.5; 0.5 1];
      params.nu0 = 10;
      params.S0 = eye(2);
      n = 100;
      % sample mu and Sigma
      mu = params.mean0 + chol(params.covMat0)*randn(2,1);
      Sigma = iwishrnd(params.S0, params.nu0);
      % generate data
      data = repmat(mu,1,n) + chol(Sigma)*randn(2,n);

    otherwise
      error('no such dataset')
  end
  % run gibbs sampler
  options.nSamples = 100;
  samples = gibbsSampler(data, params, options);

  mean(samples.mu')'
  mean(samples.Sigma,3)'

