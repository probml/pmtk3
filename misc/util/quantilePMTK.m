function y = quantilePMTK(X, p)
% Simple replacement for the stats quantile function
% Covers most but possibly not all use cases
X = sort(X(:), 1);
n = length(X);
q = [0 100*(0.5:(n-0.5))./n 100]';
y = interp1q(q, [X; X; X], 100.*p(:));

end
