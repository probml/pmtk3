function model = svmlibLinearFit(X, y, C, ignore1, ignore2, options)
% PMTK interface to svm liblinear
% Supports only classification with a linear kernel.
% Download liblinear from 
% http://www.csie.ntu.edu.tw/~cjlin/liblinear/#download

% This file is from pmtk3.googlecode.com

y = colvec(y); 
if nargin < 6
    if nunique(y) > 2
        typeSwitch = '-s 4';
    else
        typeSwitch = '';
    end
    Cswitch = sprintf('-c %f', C);
    options = sprintf('%s %s', Cswitch, typeSwitch);
        
end
model = libLinearTrain(y, sparse(X), options); % requires sparse matrix
model.C = C;
model.fitEngine = mfilename();
end
