function h= rbmVtoH(model, v)
%go from visible to hidden based on type

% This file is from pmtk3.googlecode.com


error('deprecated')
if isequal(model.type, 'BB')
    h= sigmoid(v*model.W + repmat(model.b,size(v,1),1));
elseif isequal(model.type, 'BG')
    h= v*model.W + repmat(model.b,size(v,1),1);
elseif isequal(model.type, 'GB')
    h= sigmoid(v*model.W/model.sigma + repmat(model.b,size(v,1),1));
end
