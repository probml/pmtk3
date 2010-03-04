function logp = gaussLogprobMissingData(model, X)
% Same as gaussLogprob, but supports missing data, represented as
% NaN values distributed through X. X(i, :) is still the ith case
% and model has the fields mu and Sigma. 
mu = model.mu; Sigma = model.Sigma; 
mu = rowvec(mu); 
d = size(Sigma, 2);
X = reshape(X, [], d);
n = size(X, 1);
logp = zeros(n, 1); 
for i=1:n % for each data case, marginalize out the unknown variables
    vis = ~isnan(X(i, :));
    if isempty(vis), continue; end % if no data, leave logp(i) at 0, since the probability of an empty event is 1 and log(1) = 0. 
    XiVis = X(i, vis); 
    XiVis = XiVis - mu(vis);
    logZ = (d/2)*log(2*pi) + 0.5*logdet(Sigma(vis, vis));
    logp(i) = -0.5*sum((XiVis*inv(Sigma(vis, vis))).*XiVis, 2) - logZ; 
end

end