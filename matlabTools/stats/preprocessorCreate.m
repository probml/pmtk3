function [pp] = preprocessorCreate(varargin)
% Make a preprocessor structure
% Options:
%
% standardizeX - if true, makes columsn of X zero mean and unit variance [true]
% rescaleX - if true, scale columns of X to lie in [-1, +1] [false]
% kernelFn - if not [], apply kernel fn to X  default []
% poly - if not [], specify degree of polynomial expansion

% This file is from pmtk3.googlecode.com


[pp.standardizeX, pp.rescaleX, pp.kernelFn, pp.poly, pp.addOnes] = process_options(varargin, ...
  'standardizeX', false, 'rescaleX', false, 'kernelFn', [], 'poly', [], ...
  'addOnes', false);


end
