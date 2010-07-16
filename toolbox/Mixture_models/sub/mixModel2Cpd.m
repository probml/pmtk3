function cpd = mixModel2Cpd(mixModel)
%% Convert a mixture model to a CPD

switch lower(mixModel.modelType)
    case 'mixgauss'
        cpd = condGaussCpdCreate(mixModel.mu, mixModel.Sigma); 
    case 'mixdiscrete'
        cpd = tabularCpdCreate(squeeze(mixModel.T)'); 
    otherwise
        error('cannot convert a model of type %s to a CPD', mixModel.modelType); 
end


end