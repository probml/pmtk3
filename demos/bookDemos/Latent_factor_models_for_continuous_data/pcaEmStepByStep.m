%% Illustrate EM for PCA
%PMTKauthor Cody Severinski

% Some code has been reused by pcaFitEm
setSeed(10);
n = 25; d = 2;
mu0 = mvnrnd(eye(1,d),eye(d),1);
Sigma = [1,-0.7;-0.7,1];
X = mvnrnd(mu0,Sigma,n);
k = 1;

mu = mean(X);
X = X - repmat(mu, n, 1);
X = X'; % algorithm in book uses [d,n] dimensional X

% Generating (distributional) values;
[U,S,V] = svd(Sigma,0);
Wtrue = V(:,1:k);

% Empirical (data-driven) values;
[U,S,V] = svd(cov(X));
Wdata = V(:,1:k);

% Initial (random) guess
W = rand(size(X, 1), k);

% Setup EM
converged = false;
negmseNew = -inf;
% The actual algorithm
iter = 1;
while(~converged)
  negmseOld = negmseNew;

  %% E Step
  Z = (W'*W) \ (W' * X);
  Xrecon = W*Z;

  % Plot the E-step results
  figure;
  Wortho = orth(W);
  gaussPlot2d(zeros(1,d),Sigma); hold on;
  plot(X(1,:),X(2,:),'g*');
  plot(Xrecon(1,:),Xrecon(2,:),'ko','markersize',10);
  xlim = get(gca,'XLim'); 
  line(xlim,Wortho(2)/Wortho(1) * xlim,'color','c', 'linewidth', 2);
  %line(xlim,Wdata(2)/Wdata(1) * xlim,'color','g');
  line([X(1,:);Xrecon(1,:)],[X(2,:);Xrecon(2,:)],'color','k');
  axis square;
  title(sprintf('E step %d', iter))
  printPmtkFigure(sprintf('pcaEmStepByStepEstep%d',iter'));
  %pause;

  %% M step
  W = (X*Z')/(Z*Z');
  negmseNew = -mean((Xrecon(:) - X(:)).^2)

  % Check for convergence
  converged = convergenceTest(negmseOld,negmseNew, 1e-2)

  % Plot the M-step results;
  figure;
  Wortho = orth(W);
  Z = X'*Wortho; % Z is [n,d]
  % From pcaFitEm
  [evecs, evals] = eig(Z'*Z/n);
  [evals, perm] = sort(diag(evals), 'descend');
  evecs = evecs(:, perm);
  West = W*evecs;
  Z = X'*West;
  Xrecon = Z*West';% + repmat(mu, n, 1); we are not going to recenter the data, since we are working with centered data for visualization purposes;
  gaussPlot2d(zeros(1,d),Sigma); hold on;
  plot(X(1,:),X(2,:),'g*');
  plot(Xrecon(:,1),Xrecon(:,2),'ko','markersize',10);
  xlim = get(gca,'XLim'); 
  line(xlim,Wortho(2)/Wortho(1) * xlim,'color','c', 'linewidth', 2);
  %line(xlim,Wdata(2)/Wdata(1) * xlim,'color','g');
  line([X(1,:);Xrecon(:,1)'],[X(2,:);Xrecon(:,2)'],'color','k');
  axis square;
  title(sprintf('M step %d', iter))
  printPmtkFigure(sprintf('pcaEmStepByStepMstep%d',iter'));
  %pause
  
  iter = iter + 1
  %if iter>2, break; end
end % of EM

