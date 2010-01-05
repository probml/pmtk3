
function [verbose,verboseI,debug,doPlot,maxFunEvals,maxIter,tolFun,tolX,method,...
    corrections,c1,c2,LS_init,LS,cgSolve,SR1,cgUpdate,initialHessType,...
    HessianModify,Fref,useComplex,numDiff,LS_saveHessianComp,DerivativeCheck] = ...
    minFunc_processInputOptions(o)
verbose = 1;
verboseI= 1;
debug = 0;
doPlot = 0;
method = 3;
cgSolve = 0;

if isfield(o,'Display')
    switch(o.Display)
        case 'final'
            verboseI = 0;
        case 'off'
            verbose = 0;
            verboseI = 0;
        case 'none'
            verbose = 0;
            verboseI = 0;
        case 'full'
            debug = 1;
        case 'excessive'
            debug = 1;
            doPlot = 1;
    end
end


if isfield(o,'Method')
    if strcmp(o.Method,'newton') method = 7; end
    if strcmp(o.Method,'newton0lbfgs') method = 5; cgSolve = 1; end
    if strcmp(o.Method,'newton0') method = 5; end
    if strcmp(o.Method,'bfgs') method = 4; end
    if strcmp(o.Method,'lbfgs') method = 3; end
    if strcmp(o.Method,'bb') method = 2; end
    if strcmp(o.Method,'cg')  method = 1; end
    if strcmp(o.Method,'sd') method = 0; end
end

c2 = 0.9;
LS_init = 0;
LS = 4;
Fref = 1;
% Method Specific Default Options if different than the above
if method == 2
    LS = 2;
    Fref = 10;
elseif method == 1
    c2 = 0.2;
    LS_init = 1;
elseif method == 0
    LS = 2;
    LS_init = 1;
end

maxFunEvals = getOpt(o,'MaxFunEvals',1000);
maxIter = getOpt(o,'MaxIter',500);
tolFun = getOpt(o,'TolFun',1e-5);
tolX = getOpt(o,'TolX',1e-9);
corrections = getOpt(o,'Corr',100);
c1 = getOpt(o,'c1',1e-4);
c2 = getOpt(o,'c2',c2);
LS_init = getOpt(o,'LS_init',LS_init);
LS = getOpt(o,'LS',LS);
cgSolve = getOpt(o,'cgSolve',cgSolve);
SR1 = getOpt(o,'SR1',0);
cgUpdate = getOpt(o,'cgUpdate',1);
initialHessType = getOpt(o,'initialHessType',1);
HessianModify = getOpt(o,'HessianModify',0);
Fref = getOpt(o,'Fref',Fref);
useComplex = getOpt(o,'useComplex',0);
numDiff = getOpt(o,'numDiff',0);
LS_saveHessianComp = getOpt(o,'LS_saveHessianComp',1);
DerivativeCheck = getOpt(o,'DerivativeCheck',0);
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