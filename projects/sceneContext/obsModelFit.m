function [model] = obsModelFit(X, Y)

% This file is from pmtk3.googlecode.com

[Ncases Nnodes Ndims] = size(Y); %#ok

% Fit p(y|x)
Nstates = nunique(X(:));
[model.obsmodel.localCPDs, model.obsmodel.localCPDpointers] = ...
  condGaussCpdMultiFit(X, Y, Nstates);
model.obsmodel.Nstates = Nstates;
model.obsmodel.Ndims = Ndims;

end

