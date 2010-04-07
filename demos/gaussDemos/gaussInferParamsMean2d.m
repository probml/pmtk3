%% Bayesian inference of the mean of a 2D Gaussian with fixed Sigma
%% Sample Data
setSeed(0);
muTrue      = [0.5 0.5]'; 
Ctrue       = 0.1*[2 1; 1 1];
mtrue.mu    = muTrue;
mtrue.Sigma = Ctrue;
xyrange     = [-1 1 -1 1];
ns          = [2 5 10];
X = gaussSample(mtrue, ns(end));
%% Plot Data
figure;
nr = 2; 
nc = 3;
subplot(nr, nc, 1);
plot(X(:, 1), X(:, 2), '.', 'markersize', 15);
axis(xyrange); title('data'); grid on; axis square
%% Plot Truth
subplot(nr,nc,2);
plotContour(@(x)exp(gaussLogprob(mtrue, x)), xyrange);
axis(xyrange); title('truth'); grid on; axis square
%% Plot Prior
prior.mu    = [0 0]';
prior.Sigma = 0.1*eye(2); 
subplot(nr, nc, 3); 
plotContour(@(x)exp(gaussLogprob(prior, x)), xyrange);
axis(xyrange); title('prior'); grid on; axis square
for i=1:length(ns)
    data  = X(1:ns(i), :); 
    n     = ns(i); 
    %% Update Sigma
    S0    = prior.Sigma;
    S0inv = inv(S0);
    S     = Ctrue; 
    Sinv  = inv(S);
    Sn    = inv(S0inv + n.*Sinv);
    %% Update Mu
    mu0   = prior.mu;
    xbar  = mean(data, 1)'; 
    muN   = Sn*(n.*Sinv*xbar + S0inv*mu0); %#ok<MINV> 
    %% Plot Posterior
    post.mu    = muN;
    post.Sigma = Sn; 
    subplot(nr, nc, i+3); 
    plotContour(@(x)exp(gaussLogprob(post, x)), xyrange);
    axis(xyrange); title(sprintf('post after %d obs', n)); grid on; axis square
end
printPmtkFigure gauss2dupdate


