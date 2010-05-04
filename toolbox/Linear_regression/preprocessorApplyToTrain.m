function [preproc, X] = preprocessorApplyToTrain(preproc, X)
% Apply Preprocessor to training data and memorize parameters
% preproc is initially a struct with the following fields [default]
% 
% standardizeX - if true, makes columsn of X zero mean and unit variance [true]
% rescaleX - if true, scale columns of X to lie in [-1, +1] [false]
% kernelFn - if not [], apply kernel fn to X  default []
%
% The returned preproc struct has several more fields added to it,
% which are used by  preprocessorApplyToTest

% Set defaults
if ~isfield(preproc, 'standardizeX'), preproc.standardizeX = true; end
if ~isfield(preproc, 'rescaleX'), preproc.rescaleX = false; end
if ~isfield(preproc, 'kernelFn'), preproc.kernelFn = []; end

if preproc.standardizeX
    [X, preproc.Xmu]   = centerCols(X);
    [X, preproc.Xstnd] = mkUnitVariance(X);
end

if preproc.rescaleX
    X = rescale(X, scaleXrange(1), scaleXrange(2));
    preproc.Xscale = scaleXrange;
end

if ~isempty(preproc.kernelFn)
  preproc.basis = X;
  X = preproc.kernelFn(X, preproc.basis);
end
