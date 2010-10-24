function v= rbmHtoV(model, h)
%go from hidden to visible based on type

% This file is from pmtk3.googlecode.com


error('deprecated')
if isequal(model.type, 'BB')
    v= logistic(h*model.W' + repmat(model.c,size(h,1),1));
elseif isequal(model.type, 'BG')
    v= logistic(h*model.W' + repmat(model.c,size(h,1),1));
elseif isequal(model.type, 'GB')
    v= model.sigma*h*model.W' + repmat(model.c,size(h,1),1);
end
