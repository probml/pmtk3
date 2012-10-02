function Zhat = mixModelMapLatent(model, X)
%% Compute argmax_k p( Z = k | X(i, :), model) i.e. the hard clustering

% This file is from pmtk3.googlecode.com

Zhat = maxidx(mixModelInferLatent(model, X), [], 2); 
end