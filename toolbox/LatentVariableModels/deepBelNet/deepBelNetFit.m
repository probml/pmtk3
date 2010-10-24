function model= deepBelNetFit(X, numhid, y, opts)
% Fit a deep belief network greedily, with no fine tuning
% INPUTS
% X              ... X(n,d) is in [0,1]
% numhid         ... [h1 h2 .. hn] is num hidden units per layer for n layers
% y             ... y(i) in {1..C} for top level labels, or [] if none
% opts           ... can be a struct array, one per layer, or just one struct
%                      which will be replicated. Fields are same as rbmFit.

% This file is from pmtk3.googlecode.com


%PMTKauthor Andrej Karpathy
%PMTKdata April 2010
%PMTKmodified Kevin Murphy

if nargin < 3, y = []; end
if nargin < 4, opts.verbose = true; end
H = length(numhid);
if numel(opts) == 1
  opts = repmat(opts, 1, H);
end
[model.layers, model.nparams] = dbnFit(X, numhid, y, opts);
model.modelType = 'deepBelNet';
end


function [models, nparams] = dbnFit(X, numhid, y, opts)
% returns cell array of rbms

H=length(numhid);
models = cell(H,1);
inputData = X;
nparams = 0;
for i=1:H
  if opts(i).verbose, fprintf('\n *** training layer %d\n', i); end
  if i==H
    opts(i).y = y; % add labels to last layer only
  end
  models{i} = rbmFit(inputData, numhid(i), opts(i));
  inputData = rbmInferLatent(models{i}, inputData);
  nparams = nparams + models{i}.nparams;
end

end
