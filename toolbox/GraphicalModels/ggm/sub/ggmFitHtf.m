function [precMat, iter] = ggmFitHtf(S, G, maxIter)
% MLE for a precision matrix given known zeros in the graph
% S is d*d sample covariance matrix
% G is d*d adjacency matrix
% We use the algorithm due to 
% Hastie, Tibshirani & Friedman ("Elements" book, 2nd Ed, 2008, p633)

% This file is from pmtk3.googlecode.com


%PMTKauthor Baback Moghaddam

p = length(S); 
if nargin < 3, maxIter = 30; end

W = S; % W = inv(precMat)
precMat = zeros(p,p);
beta = zeros(p-1,1);
iter = 1;
converged = false;
normW = norm(W);
while ~converged
  for i = 1:p
    % partition W & S for i
    noti = [1:i-1 i+1:p];
    W11 = W(noti,noti);
    w12 = W(noti,i);
    s22 = S(i,i);
    s12 = S(noti,i);

    % find G's non-zero index in W11
    idx = find(G(noti,i));  % non-zeros in G11
    beta(:) = 0;
    beta(idx) = W11(idx,idx) \ s12(idx);

    % update W
    w12 = W11 * beta;
    W(noti,i) = w12 ;
    W(i,noti) = w12';

    % update precMat (technically only needed on last iteration)
    p22 = max([0  1/(s22 - w12'*beta)]);  % must be non-neg
    p12 = -beta * p22;
    precMat(noti,i) = p12 ;
    precMat(i,noti) = p12';
    precMat(i,i) = p22;
  end
  converged =  convergenceTest(norm(W), normW) || (iter > maxIter);
  normW = norm(W);
  iter = iter + 1;
end

% ensure symmetry 
precMat = (precMat + precMat')/2;

end
