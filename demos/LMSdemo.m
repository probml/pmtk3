%% Least means squares (Widrow-Hoff) Demo
%
%%

% This file is from pmtk3.googlecode.com

[X,y]=contoursSSEdemo; % makes data X, y and plots surface

d = 2;
w0 = [-0.5;2]; % randn(d,1);

options.batchsize = 1;
options.verbose = true;
options.storeParamTrace = true;
options.storeFvalTrace = true;
options.maxUpdates = 20;


lambda = 0;
%funObjXy = @(w,X,y) penalizedL2(w, @(ww) LinregLossScaled(ww, X, y), lambda);
funObjXy = @(ww,XX,yy) LinregLossScaled(ww, XX, yy);
funObj = @(w) funObjXy(w, X, y);

% batch
% [x,f,exitflag,output] = minFunc(funObj,x0,options,varargin)
opt.verbose = 'none';
opt.method = 'lbfgs'
opt.derivativeCheck = 'on';
[wopt, fopt, exitflag, outputOpt] = minfunc(funObj, w0, opt);
outputOpt.trace.fval'
what = X\y

[w, f, exitflag, output] = stochgradSimple(funObjXy, w0, options, X, y);
trace = output.trace; 
[fvalTraceAvg, fvalTrace] = stochgradTracePostprocess(trace, funObjXy, X, y);
 
contoursSSEdemo(true);
whist2 = trace.params';
hold on
plot(whist2(1,:), whist2(2,:), 'ko-', 'linewidth',2);
title('black line = LMS trajectory towards LS soln (red cross)')
printPmtkFigure('lmsTraj')


figure;
plot(fvalTrace, 'ko-', 'linewidth', 2);
title('obj vs iteration')
horizontalLine(fopt, 'linewidth', 2);
printPmtkFigure('lmsRssHist')

if 0
figure;
plot(trace.stepSize, 'ko-', 'linewidth', 2);
title('stepsize vs iteration')
end
