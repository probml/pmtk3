function [logp] = mixStudentLogprob(model, X)
% logp(i) = log p(X(i,:) | model)
% logPz(i,k) = log p(z=k, X(i,:), model) unnormalized
%PMTKlatentModel mixStudent
[z, pz, logp] = mixStudentInfer(model, X); %#ok


end