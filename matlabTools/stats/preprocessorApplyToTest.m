function [X] = preprocessorApplyToTest(preproc, X)
% Transform the test data in the same way as the training data

% This file is from pmtk3.googlecode.com


if isempty(preproc), return; end

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
if isfield(preproc, 'poly') && ~isempty(preproc.poly)
    X = degexpand(X, preproc.poly, false);
end
if isfield(preproc, 'addOnes') && preproc.addOnes
    X = addOnes(X);
end
end
