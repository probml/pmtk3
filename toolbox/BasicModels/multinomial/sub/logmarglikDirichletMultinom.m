function L = logmarglikDirichletMultinom(N, alpha)
% L(i) = marginal liklelihood of counts N(i,:) given Dirichlet prior alpha(i,:)

% This file is from pmtk3.googlecode.com

L = gammaln(sum(alpha     , 2)) - ...
    gammaln(sum(N + alpha , 2)) + ...
    sum(gammaln(N + alpha), 2)  - ...
    sum(gammaln(alpha)    , 2);
end
