function [pZ, pX] = noisyMixModelInfer(model, Y)
% Y is Ncases * Nnodes * Ndims
% so Y(i,j,:) are the observations for node j in case i
%
% Z -> Xj -> Yj
%
% pZ(i, k) responsibility of cluster k for case i
% pX(i,  c, j) = p(Xj = c | case i) 
%
% This interface is similar to mixInfer, and is batch-oriented.
% Use noisyMixModelInferNodes for single cases.
 
[Ncases, Nnodes, Ndims] = size(Y);
Nmix = model.mixmodel.nmix;
Nstates = model.obsmodel.Nstates;
pZ = zeros(Ncases, Nmix);
pX = zeros(Ncases, Nstates, Nnodes);
for i=1:Ncases
  [pZ(i,:), pX(i,:,:)] = noisyMixModelInferNodes(model, reshape(Y(i,:,:), [Nnodes Ndims])');
end

end


