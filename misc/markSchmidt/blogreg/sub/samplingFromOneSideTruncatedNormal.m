function x = samplingFromOneSideTruncatedNormal(m, sd, left)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input:
%   m is the mean of the normal distribution.
%   sd is the standard deviation of the normal distribution.
%   left is the bound of x.
% Output:
%   x is the random number following truncated normal with mean m, 
%   standard deviation sd and x > left.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This method is based on paper "Simulation of truncated normal variables"
% by Robert (1995) 
%
% Written by Xuan Xuang
% Standardize 
low = (left - m)/sd;

% Pick the best parameter lambda for translated exponetial distribution 
lambda = (low + sqrt(low^2+4))/2;
if low >= lambda
    lambda = low;
end;


u =1; prob = 0;

while u > prob
    
    % z follows translated exponetial distribution
    z = exprnd(1/lambda);
    z = z + low;
    
    % compute the acceptance probability
    if low < lambda
        prob = exp(-(lambda-z)^2/2);
    else
        prob = exp((low-lambda)^2)*exp(-(lambda-z)^2/2);
    end

    u = rand();
end

x = m + z*sd;

