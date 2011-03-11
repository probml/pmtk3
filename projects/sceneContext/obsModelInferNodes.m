function [pX] = obsModelInferNodes(model, Y)
% Y is Ndims * Nnodes 
% so Y(:,j)  are the observations for node j 
%

% pX(c, j) = p(Xj = c)


softev = localEvToSoftEv(model.obsmodel, Y);
%softev(:,j) with |Xj|=Nstates rows

pX = normalize(softev, 1); 

end

