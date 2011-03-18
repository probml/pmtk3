function [nodeBel] = discreteInferNodes(model, softev)
% Combine model's independent prior with likelihood to get posterior
% nodeBel(k,t) propto softev(k,t) * model.T(k,t)

nodeBel = normalize(softev .* model.T, 1);

end
