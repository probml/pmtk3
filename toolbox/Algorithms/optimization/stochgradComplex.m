function [wavg, f, exitflag, output] = stochgrad(objFun, w0, options, X, y, varargin)
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


%PMTKauthor Kevin Swersky, Kevin Murphy

nTrain = size(X,1);
perm = randperm(nTrain);
X = X(perm,:); y = y(perm);
exitflag = [];

minFuncArgs = [];
minFuncArgs.derivativeCheck = 'off';
minFuncArgs.display = 'none';
%minFuncArgs.display = 'iter';
options.maxIter = 100;
minFuncArgs.maxFunEvals = 500;
minFuncArgs.TolFun = 1e-3; % defauly 1e-5
minFuncArgs.TolX = 1e-3; % default 1e-5
minFuncArgs.Method = 'bfgs';

maxbatch = getOpt(options, 'maxbatch', min(nTrain, 1000));
batchsize =  getOpt(options,'batchsize',[]);
%batchsizeFn  = @(epoch) min(maxbatch, 10*2^(epoch-1));
batchsizeFn  = @(epoch) min(maxbatch, 10*(epoch));
batchsizeFn =  getOpt(options,'batchsizeFn', batchsizeFn);
minfuncOpt = getOpt(options, 'minfuncOpt', minFuncArgs);
maxepoch = getOpt(options, 'maxepoch', 5);
maxUpdates = getOpt(options, 'maxUpdates', 1000);
method = getOpt(options, 'method', 'minfunc');
avgstart = getOpt(options, 'avgstart', 5);
verbose = getOpt(options, 'verbose', false);
storeParamTrace = getOpt(options, 'storeParamTrace', false);
storeFvalTrace = getOpt(options, 'storeFvalTrace', false);
stepSizeFn = getOpt(options, 'stepSizeFn',  @(t) 0.1*0.999^t);
%stepSizeFn = getOpt(options, 'stepSizeFn',  @(t) 0.1*(1/t)^1);
convTol = getOpt(options, 'convTol', 1e-7);
minNupdates = getOpt(options, 'minNupdates', 10);
finalMinfunc = getOpt(options, 'finalMinfunc', false);

%% Pre-compute mini-batches
if ~isempty(batchsize)
  [batchdata, batchlabels] = batchify(X, y, batchsize);
end

w  = w0;
fbAvg = 0;
% Initialize Trace
trace.fval = [];
trace.fvalAvg = [];
trace.fvalMinibatch = [];
trace.fvalMinibatchAvg = [];
trace.funcCount = [];
trace.params = [];
trace.paramsAvg = [];
trace.stepSize = [];


%% Main loop
nupdates = 1;
for epoch=1:maxepoch
   if verbose,		fprintf('epoch %d, nupdates so far %d\n', epoch, nupdates); end
   if isempty(batchsize)
     bs = batchsizeFn(epoch);
     [batchdata, batchlabels] = batchify(X, y, bs);
     if verbose, fprintf('epoch %d, batch size %d\n', epoch, bs); end
   end
   num_batches = numel(batchlabels);
	for b=1:num_batches
    bdata = batchdata{b};
    blabels = batchlabels{b};
    if verbose && mod(b,10)==0,	fprintf('epoch %d batch %d fbavg %f\n', epoch, b, fbAvg); end
    % Evaluate objective and gradient on mini-batch
    switch lower(method)
      case 'sgd'
        [fb, g] = objFun(w, bdata, blabels, varargin{:});
        funEvals = 1;
      case 'minfunc'
        [wnew, fb, exitflag, output] = minFunc(objFun, w, minfuncOpt, bdata, blabels, varargin{:});
        funEvals = output.funcCount;
        g = w-wnew; % implicit gradient
    end
    % Update params
    eta = stepSizeFn(nupdates);
    w = w - eta*g; 
    % Store objective
    fbAvg = fbAvg - (1/nupdates)*(fbAvg - fb);
    trace.fvalMinibatch(end+1,1) = fb;
    trace.fvalMinibatchAvg(end+1) = fbAvg;
    
    % Convergence test
    if nupdates > minNupdates
      %converged = norm(w-wold) < convTol;
      windowSize = 5;
      fbFilt = filter(ones(1,windowSize)/windowSize,1,trace.fvalMinibatch(end-10:end));
      fbDelta = diff(fbFilt);
      converged = mean(fbDelta) < convTol; 
      %[converged] = convergenceTest(fbAvg, fbAvgOld, convTol);
    else
      converged = false;
    end
    
    % Parameter averaging
    if (nupdates >= avgstart)
      K = nupdates - avgstart + 1;
      wavg = wavg - (1/(K))*(wavg - w);
    else
      wavg = w;
    end
    nupdates = nupdates + 1;
    
    % Update Trace
  
    trace.funcCount(end+1,1) = funEvals;
    if storeParamTrace
      % Storing the history of the parameters may take a lot of space
      trace.params(end+1,:) = w(:)';
      trace.paramsAvg(end+1,:) = wavg(:)';
      assert(approxeq(wavg, mean(trace.params(avgstart:end, :), 1)))
    end
    if strcmpi(method, 'sgd')
      trace.stepSize(end+1,1) = eta;
    end
    if storeFvalTrace
      % evaluating the objective on all the data is expensive
      % and negates any speed benefits of SGD
      trace.fval(end+1) =  objFun(w, X, y, varargin{:});
      trace.fvalAvg(end+1) =  objFun(wavg, X, y, varargin{:});
    end
    if nupdates > maxUpdates || converged, break; end
  end % next batch
  if nupdates > maxUpdates, break; end
end % next epoch

if verbose 
  fprintf('finished after %d updates\n', nupdates)
end
if finalMinfunc
  % Do a final batch fitting  on the largest batch size
  % you can store, initialized from SGD
  if verbose, fprintf('final bacth fitting on %d examples\n', maxbatch); end
   [wavg, f, exitflag2, output2] = minFunc(objFun, wavg, minfuncOpt, ...
     X(1:maxbatch,:), y(1:maxbatch), varargin{:});
    trace.params(end+1,:) = wavg(:)';
    trace.paramsAvg(end+1,:) = wavg(:)';
end
% Compute batch objective
f =  objFun(wavg, X, y, varargin{:});
output.w = w;
output.wavg = wavg;
output.trace = trace;
output.funcCount  = sum(trace.funcCount);


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

function [groups] = mkBatches(nTrain, batchsize)
  num_batches = ceil(nTrain/batchsize);
  groups = repmat(1:num_batches,1,batchsize);
  groups = groups(1:nTrain);
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
