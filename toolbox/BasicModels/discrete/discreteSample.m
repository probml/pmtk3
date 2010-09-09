function S = discreteSample(arg1, n)
%% Sample from a discrete distribution
%
% S = discreteSample(model, n); OR  
% S = discreteSample(T, n);
% 
% T is of size K-by-d where K is the number of states and d is the number
% of distributions; n is the number of samples. Each *column* of T sums to
% one. 
%
% model, if specified, must have the field T
%
% S is of size n-by-d
%%

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    T = model.T;
    d = model.d;
else
    T = arg1;
    [K, d] = size(T); 
end

if nargin < 2
    n = 1;
end

S = zeros(n, d); 
for i=1:d
   S(:, i) = sampleDiscrete(T(:, i), n, 1); % call out to sampleDiscrete
end
end
