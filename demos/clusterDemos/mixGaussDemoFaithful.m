function mixGaussDemoFaithful
% reproduce Bishop fig 9.8

close all
setSeed(0);
K = 2;
X = load('faithful.txt');
X = standardizeCols(X);

% specify initial params to make for a pretty plot
mu = [-1.5 1.5; 1.5 -1.5]' + 1*randn(2,2);
Sigma = repmat(0.1*eye(2),[1 1 K]);
mixweight = normalize(ones(1,K));
[model, loglikHist] = mixGaussFitEm(X, K, ...
   'maxIter', 10, 'plotfn', @plotfn,...
   'mu', mu, 'Sigma', Sigma, 'mixweight', mixweight);
figure;
plot(loglikHist, 'o-', 'linewidth', 3)
xlabel('iter')
ylabel('average loglik')
end

%%%%%%

function plotfn(X,  mu, Sigma, mixweight, post, loglik, iter)


str = sprintf('iteration %d, loglik %5.4f\n', iter, loglik);
figure; plot(X(:,1), X(:,2), '.', 'markersize', 10)
hold on
plot(mu(1,:), mu(2,:),'or','linewidth',2);
K  = size(mu,2);
for k=1:K
   gaussPlot2d(mu(:,k), Sigma(:,:,k));
end
title(str)
axis square

end
