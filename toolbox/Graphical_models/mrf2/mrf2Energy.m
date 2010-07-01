function e = mrf2Energy(model, y)
% Compute unnormalized negative log probability, where p(y) = 1/Z exp(-E(y))
% E(y) = -[sum_i log phi(i,y(i)) + sum_{j in Ni} log phi(i,j,y(i),y(j))]
% 
%PMTKlatentModel mrf2
e = -UGM_LogConfigurationPotential(y, model.nodePot, model.edgePot, ...
  model.edgeStruct.edgeEnds);

end