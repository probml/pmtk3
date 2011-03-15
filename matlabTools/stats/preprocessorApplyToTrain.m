function [preproc, X] = preprocessorApplyToTrain(preproc, X)
% Apply Preprocessor to training data and store updated
% parameters inside pp object for use at test time

% This file is from pmtk3.googlecode.com

if isempty(preproc), return; end

% For backwards compatibility, we replicate the
% behavior of preprocessorCreate
if ~isfield(preproc, 'standardizeX'), preproc.standardizeX = false; end
if ~isfield(preproc, 'rescaleX'), preproc.rescaleX = false; end
if ~isfield(preproc, 'kernelFn'), preproc.kernelFn = []; end
if ~isfield(preproc, 'poly'), preproc.poly = []; end 
if ~isfield(preproc, 'addOnes'), preproc.addOnes = false; end
  
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
  assert(preproc.poly > 0); 
  X = degexpand(X, preproc.poly, false);
end

if  preproc.addOnes
    X = addOnes(X);
end

end
