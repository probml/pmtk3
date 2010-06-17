%% Bayesian model selection demo for polynomial regression
% This illustartes that if we have more data, Bayes picks a more complex model.
%
% Based on a demo by Zoubin Ghahramani

% We use the pmtk wrapper to Tao Chen's code
% and to Ian Nabney's netlab code. The netlab version seems
% to work better when N is small (~8), but both give the same
% results when N is large (~ 32).
Ns = [8 32];
for ni=1:length(Ns)
  ndata = Ns(ni);
  
  setSeed(2);
  
  x1d=rand(ndata,1)*10; % input points
  e=randn(ndata,1); % noise
  ytrain = (x1d-4).^2 + 5*e; % actual function
  plotvals1d = [-2:0.1:12]'; % uniform grid for plotting/ testing
  trueOutput = (plotvals1d-4).^2;
  
  fitFns = {...
    @(X,y) linregFitBayes(X,y,'prior','eb'), ...
    @(X,y) linregNetlabFitEb(X, y)};
  predFns = {...
    @(m, X) linregPredictBayes(m, X), ...
    @(m, X) linregNetlabPredict(m, X)};
  names = {'pmtk', 'netlab'};
  
  for i=1:length(names)
    fitFn = fitFns{i}; predFn = predFns{i}; name = names{i};
    
    
    figure;
    degs = [0 1 2 3];
    for m=1:length(degs)
      deg=degs(m);
      X = polyBasis(x1d, deg);
      X = X(:,2:end); % omit column of 1s
      Xtest = polyBasis(plotvals1d, deg);
      Xtest = Xtest(:, 2:end);
      
      [model, logev(m)] = fitFn(X, ytrain);
      [mu, sig2] = predFn(model, Xtest);
      sig = sqrt(sig2);
      
      % Plot the data, the original function, and the trained network function.
      subplot(2,2,m)
      plot(x1d, ytrain, 'ok')
      hold on
      plot(plotvals1d, trueOutput, 'g-');
      plot(plotvals1d, mu, '-r')
      plot(plotvals1d, mu + sig, 'b:');
      plot(plotvals1d, mu - sig, 'b:');
      title(sprintf('d=%d, logev=%5.3f, %s', deg, logev(m), name))
    end
    printPmtkFigure(sprintf('linregEbModelSelVsN%dFn%s', ndata, name))
    
    
    figure;
    PP=exp(logev);
    PP=PP/sum(PP);
    bar(degs, PP)
    axis([-0.5 length(degs)+0.5 0 1]);
    set(gca,'FontSize',16);
    aa=xlabel('M'); set(aa,'FontSize',20);
    aa=ylabel('P(M|D)'); set(aa,'FontSize',20);
    title(sprintf('N=%d, %s', ndata, name))
    printPmtkFigure(sprintf('linregEbModelSelVsN%dPost%s', ndata, name))
  end % for i
  
end % for ni
