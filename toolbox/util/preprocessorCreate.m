function [p[] = preprocessorCreate(varargin)
% Make a preprocessor structure
% Options:
%
% standardizeX - if true, makes columsn of X zero mean and unit variance [true]
% rescaleX - if true, scale columns of X to lie in [-1, +1] [false]
% kernelFn - if not [], apply kernel fn to X  default []
%

[pp.standardizeX, pp.rescaleX, pp.kernelFn] = process_options(varargin, ...
  'standardizeX', true, 'rescaleX', false, 'kernelFn', []);


end
