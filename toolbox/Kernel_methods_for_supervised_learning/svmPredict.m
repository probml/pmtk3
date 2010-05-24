function [yhat, f] = svmPredict(model, Xtest)
% Return svm predictions.
% model is a struct as returned by svmFit()
% Xtest(i, :) is the ith case. 
% f  is the signed distance to separating hyperplane

if isfield(model, 'standardizeX') && model.standardizeX
    Xtest = mkUnitVariance(centerCols(Xtest)); 
end
if isfield(model, 'rescaleX') && model.rescaleX
   Xtest = rescaleData(Xtest, -1, 1, model.minx, model.rangex); 
end
switch model.fitEngine
    case 'svmlibFit'
        predictFn = @svmlibPredict;
    case 'svmlibLinearFit'
        predictFn = @svmlibLinearPredict;
    case 'svmlightFit'
        predictFn = @svmlightPredict;
    case 'svmQPclassifFit'
        predictFn = @svmQPclassifPredict;
    case 'svmQPregFit'
        predictFn = @svmQPregPredict;
    otherwise
        predictName = [model.fitEngine(1:end-3), 'predict'];
        if exist(predictName, 'file')
            predictFn = str2func(predictName);
        else
            error('Could not find %s', predictName);
        end
end
if nargout < 2
    yhat = predictFn(model, Xtest);
else
    % currrently only supported by svmQPclassif*
    [yhat, f] = predictFn(model, Xtest); 
end

end