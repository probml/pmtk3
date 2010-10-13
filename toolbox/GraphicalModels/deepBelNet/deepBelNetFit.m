function model= deepBelNetFit(X, numhid, y, opts)
% Fit a deep belief network greedily, with no fine tuning
% INPUTS
% X              ... X(n,d) is in [0,1]
% numhid         ... [h1 h2 .. hn] is num hidden units per layer for n layers
% y             ... y(i) in {1..C} for top level labels, or [] if none
% opts           ... can be a struct array, one per layer, or just one struct
%                      which will be replicated. Fields are same as rbmFit.

%PMTKauthor Andrej Karpathy
%PMTKdata April 2010
%PMTKmodified Kevin Murphy

if nargin < 3, y = []; end
if nargin < 4, opts.verbose = true; end
H = length(numhid);
if numel(opts) == 1
  opts = repmat(opts, 1, H);
end
model.layers = dbnFit(X, numhid, y, opts);
model.modelType = 'deepBelNet';
end


function model= dbnFit(X, numhid, y, opts)
% returns cell array of rbms

H=length(numhid);
model=cell(H,1);
if H==1
  tmp = opts(1); tmp.y = y;
  model{1}= rbmFit(X, numhid(1), tmp);
else
  %train the first RBM on data
  if opts(1).verbose, fprintf('\n *** training layer 1\n'); end
  model{1}= rbmFit(X, numhid(1), opts(1));
  
  %train all other RBM's on top of each other
  for i=2:H-1
    if opts(i).verbose, fprintf('\n *** training layer %d\n', i); end
    model{i} = rbmFit(model{i-1}.top, numhid(i), opts(i));
  end
  
  %the last RBM has access to labels too
  if opts(H).verbose, fprintf('\n *** training last layer\n'); end
  tmp = opts(H); tmp.y = y;
  model{H}= rbmFit(model{H-1}.top, numhid(end), tmp);
end
end
