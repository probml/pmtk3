function S = poissonSample(arg1, arg2)
%% Sample n integers from a poisson distribution with parameter lambda
%S = poissonSample(model, n); OR S = poissonSample(lambda, n); 

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    lambda = model.lambda;
else
    lambda = arg1; 
end
if nargin < 2
    n = 1;
else
    n = arg2;
end

if numel(lambda) ==  1
    lambda = repmat(lambda, n, 1); 
end
lambda = colvec(lambda); 
S      = zeros(n, 1); 
j      = 1:n;
p      = zeros(numel(j),1);
while ~isempty(j)
    p    = p - log(rand(numel(j), 1));
    t    = p < lambda(j);
    j    = j(t);
    p    = p(t);
    S(j) = S(j) + 1;
end
