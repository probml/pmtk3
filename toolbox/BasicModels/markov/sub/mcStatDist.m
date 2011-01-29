function pi = mcStatDist(T, method)
% Compute the stationary distribution of a discrete state, discrete time Markov chain
% Returns a row vector

% This file is from pmtk3.googlecode.com

% Example
% T=[0.7 0.2 0.1; 0 0.5 0.5; 0 0.9 0.1]
% mcStatDist(T) =  0.0000    0.6429    0.3571
%
% T=[0 1 0; 0.5 0 0.5;1 0 0]; 
% mcStatDist(T) = 0.4000    0.4000    0.2000
% Note: method 1 fails in this case!

K = length(T);
if nargin < 2, method = 2; end
switch method
    case 1 
        [V,D]=eig(T');
        D=diag(D);
        ndx= find(D==1);
        if isempty(ndx)
          error('cant use eigenvector method')
        end
        pi = normalize(V(:,ndx))';
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

