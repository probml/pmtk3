function [L, LL] = mixDiscreteLogprob(model, X)
% L(i) = log p(X(i,:) | model)
% LL(i) = log p(X(i, j) | model)
%PMTKlatentModel mixDiscrete
[z, pz, L] = mixDiscreteInfer(model, X);
if nargout > 1
    LL = log(pz); 
end



end