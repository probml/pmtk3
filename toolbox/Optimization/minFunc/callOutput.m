function [] = callOutput(outputFcn,x,state,i,funEvals,f,t,gtd,g,d,opt,varargin)

optimValues.iteration = i;
optimValues.funccount = funEvals;
optimValues.fval = f;
optimValues.stepsize = t;
optimValues.directionalderivative = gtd;
optimValues.gradient = g;
optimValues.searchdirection = d;
optimValues.firstorderopt = opt;

outputFcn(x,optimValues,state,varargin{:});