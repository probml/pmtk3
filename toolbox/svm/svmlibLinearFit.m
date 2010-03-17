function model = svmlibLinearFit(X, y, C, options)
% PMTK interface to svm liblinear
% Supports only classification with a linear kernel.


if nargin < 4
    if nunique(y) > 2
        typeSwitch = '-s 4';
    else
        typeSwitch = '';
    end
    Cswitch = sprintf('-c %f', C);
    options = sprintf('%s %s', Cswitch, typeSwitch);
        
    
end
model = train(y, sparse(X), options); % requires sparse matrix
model.C = C;
model.engine = 'liblinear';
end