function pi = mcStatDist(T, method)
% Compute the stationary distribution of a discrete state, discrete time Markov chain
% Returns a row vector
% Based on code by Andrew M. Ross http://www.lehigh.edu/~amr5/q/matlab.html

% This file is from pmtk3.googlecode.com


K = length(T);
if nargin < 2, method = 2; end
switch method
    case 1 % numerically unstable method
        evecs = eig(T');
        pi = normalize(evecs(:,1))';
    case 2 % resnick method
        pi = ones(1,K) / (eye(K)-T+ones(K,K));
    case 3 % replace one equation
        tmp = eye(K)-T;
        tmp(:,K) = 1;
        pi = [zeros(1, K-1) 1] / tmp;
    case 4 % power method
        %pi = rand(1,K)*(T^100);
        pi = rand(1,K);
        for i=1:100
            pi = normalize(pi*T);
        end
end

