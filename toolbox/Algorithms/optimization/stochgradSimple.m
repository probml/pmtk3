function [w, f, exitflag, output] = stochgradSimple(objFun, w0, options, X, y, varargin)
% Stochastic gradient descent with averaging
% Interface is similar to minfunc except you must explicitly
% pass in X and y, which is needed for mini-batching
% Example:
% opt.batchsize = 10; opt.method = 'sgd'; w=stochgrad(objFn, winit, opt, X, y, lambda, ...)
%
% This repeatedly calls w = objFn(Xb, y, b lambda, ...)
% where Xb, yb are for batch b
%
% If using sgd, we use a step size of the form
%  initStepSize * (1/nupdates)^stepSizeDecay
%
% Optional arguments:

% This file is from pmtk3.googlecode.com


%PMTKauthor  Kevin Murphy

batchsize =  getOpt(options,'batchsize',10);
maxepoch = getOpt(options, 'maxepoch', 500);
maxUpdates = getOpt(options, 'maxUpdates', 1000);
verbose = getOpt(options, 'verbose', false);
storeParamTrace = getOpt(options, 'storeParamTrace', false);
%lambda = getOpt(options, 'lambda', 1);
t0 = getOpt(options, 't0', 1);
eta0 = getOpt(options, 'eta0', 0.1);
% Leon Bottou
%stepSizeFn = getOpt(options, 'stepSizeFn',  @(t) 1/(lambda*(t+t0)));
% Nic Schraudolph
stepSizeFn = getOpt(options, 'stepSizeFn',  @(t) eta0*t0/(t+t0));

[batchdata, batchlabels] = batchify(X, y, batchsize);
num_batches = numel(batchlabels);
if verbose, fprintf('%d batches of size %d\n', num_batches, numel(batchlabels{1})); end

w = w0;
% Initialize Trace
trace.fvalMinibatch = [];
trace.params = [];
trace.stepSize = [];

%% Main loop
nupdates = 1;
for epoch=1:maxepoch
   if verbose,		fprintf('epoch %d\n', epoch); end
	for b=1:num_batches
    bdata = batchdata{b};
    blabels = batchlabels{b};
    if verbose && mod(b,100)==0,		fprintf('epoch %d batch %d nupdates %d\n', epoch, b, nupdates); end
 
    [fb, g] = objFun(w, bdata, blabels, varargin{:});
    eta = stepSizeFn(nupdates);
    w = w - eta*g; % steepest descent
 
    nupdates = nupdates + 1;
    % Update Trace
    trace.fvalMinibatch(end+1,1) = fb;
    if storeParamTrace
      % Storing the history of the parameters may take a lot of space
      trace.params(end+1,:) = w(:)';
    end  
    trace.stepSize(end+1,1) = eta;
    if nupdates > maxUpdates, break; end
  end % next batch
  if nupdates > maxUpdates, break; end
end % next epoch

output.trace = trace;
f = []; %  objFun(w, X, y, varargin{:});
exitflag = [];

end


function [batchdata, batchlabels] = batchify(X, y, batchsize)
  nTrain = size(X,1);
   num_batches = ceil(nTrain/batchsize);
  groups = repmat(1:num_batches,1,batchsize);
  groups = groups(1:nTrain);
  batchdata = cell(1, num_batches);
  batchlabels = cell(1, num_batches);
  for i=1:num_batches
    batchdata{i} = X(groups == i,:);
    batchlabels{i} = y(groups == i,:);
    if 0, fprintf('batch %d has %d examples\n', i, length(batchlabels{i})); end
  end
end

function [v] = getOpt(options,opt,default)
if isfield(options,opt)
    if ~isempty(getfield(options,opt))
        v = getfield(options,opt);
    else
        v = default;
    end
else
    v = default;
end
end
