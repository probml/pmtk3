function [X] = preprocessorApplyToTest(preproc, X)
% Apply Preprocessor to test data 

if isempty(preproc), return; end

% Transform the test data in the same way as the training data
if isfield(preproc, 'Xmu')
    X = centerCols(X, preproc.Xmu);
end
if isfield(preproc, 'Xstnd')
    X = mkUnitVariance(X, preproc.Xstnd);
end
if isfield(preproc, 'Xscale')
    X = rescaleData(X, preproc.Xscale(1), preproc.Xscale(2));
end
if isfield(preproc, 'kernelFn') && ~isempty(preproc.kernelFn)
    X = preproc.kernelFn(X, preproc.basis);
end
