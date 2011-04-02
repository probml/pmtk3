
function model = setMixPrior(model, mixPrior)
%% Set the mixture prior
nmix = model.nmix; 
if isempty(mixPrior)
    model.mixPrior = 2*ones(1, nmix);
end
if ischar('none') && strcmpi(mixPrior, 'none'); 
    model.mixPrior = ones(1, nmix);
    model.mixPriorFn = @(m)0;
else
    model.mixPriorFn  = @(m)log(m.mixWeight(:))'*(m.mixPrior(:)-1);
end
if isscalar(model.mixPrior)
    model.mixPrior = repmat(model.mixPrior, 1, nmix); 
end
end
