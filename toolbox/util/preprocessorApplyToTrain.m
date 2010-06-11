function [preproc, X] = preprocessorApplyToTrain(preproc, X)
% Apply Preprocessor to training data and store updated
% parameters inside pp object for use at test time


if preproc.standardizeX
    [X, preproc.Xmu]   = centerCols(X);
    [X, preproc.Xstnd] = mkUnitVariance(X);
end

if preproc.rescaleX
    if ~isfield(preproc, 'Xscale')
       preproc.Xscale = [-1 1]; 
    end
    X = rescaleData(X, preproc.Xscale(1), preproc.Xscale(2));
    
end

if ~isempty(preproc.kernelFn)
    preproc.basis = X;
    X = preproc.kernelFn(X, preproc.basis);
end

if ~isempty(preproc.poly)
  X = degexpand(X, preproc.poly, false);
end

if  preproc.addOnes
    X = addOnes(X);
end

end