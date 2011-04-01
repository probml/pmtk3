function [params, logLik] = learnEm(data, funcNames, params, options)
% learnEm and learnEm_ver1 are same files.
% learnEmOld is the old inefficient version

%TODO modify convergence criteria to parameters in a better way
  
  [lowerBoundTol, maxNumOfItersLearn, debug, display, checkConvergenceIters, checkConvergenceMethod] = myProcessOptions(options,'lowerBoundTol',0.01,'maxNumOfItersLearn',100,'debug', 0, 'display', 1, 'checkConvergenceIters',1, 'checkConvergenceMethod','objFun');

  % get function names
  inferFunc = funcNames.inferFunc;
  maxParamsFunc = funcNames.maxParamsFunc;

  options.computeSs = 1;
  options.computeLogLik = 1;

  % iterate
  logLik = [];
  vals = [];
  for iter = 1:maxNumOfItersLearn
    if mod(iter, checkConvergenceIters) ~= 0
      % inference
      [ss] = inferFunc(data, params, options);
    else
      [ss, logLik(end+1)] = inferFunc(data, params, options);
      % covergence
      [converged, incr] = isConverged(logLik, lowerBoundTol, 'objFun');
      if display
        fprintf('Iter %d Lower bound %f, increase by %f\n',iter,logLik(end), incr);
      end
      if converged; break; end;
      if incr < -1e-10 
        warning('Lower bound decreased');
      end
    end
    % maximize 
    params = maxParamsFunc(ss, data, params, options);
  end


