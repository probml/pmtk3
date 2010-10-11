function h= rbmVtoH(model, v)
%go from visible to hidden based on type

if isequal(model.type, 'BB')
    h= logistic(v*model.W + repmat(model.b,size(v,1),1));
elseif isequal(model.type, 'BG')
    h= v*model.W + repmat(model.b,size(v,1),1);
elseif isequal(model.type, 'GB')
    h= logistic(v*model.W/model.sigma + repmat(model.b,size(v,1),1));
end