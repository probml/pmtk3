
function [verbose,verboseI,debug,doPlot,maxFunEvals,maxIter,tolFun,tolX,method,...
    corrections,c1,c2,LS_init,LS,cgSolve,SR1,cgUpdate,initialHessType,...
    HessianModify,Fref,useComplex,numDiff,LS_saveHessianComp,...
    DerivativeCheck,Damped,HvFunc,bbType,cycle,boundStepLength,...
    HessianIter,outputFcn] = ...
    minFunc_processInputOptions(o)

% Constants
SD = 0;
CSD = 1;
CG = 2;
BB = 3;
LBFGS = 4;
BFGS = 5;
NEWTON0 = 6;
NEWTON = 7;
TENSOR = 8;

verbose = 1;
verboseI= 1;
debug = 0;
doPlot = 0;
method = LBFGS;
cgSolve = 0;

o = toUpper(o);

if isfield(o,'DISPLAY')
    switch(upper(o.DISPLAY))
        case 0
            verbose = 0;
            verboseI = 0;
        case 'FINAL'
            verboseI = 0;
        case 'OFF'
            verbose = 0;
            verboseI = 0;
        case 'NONE'
            verbose = 0;
            verboseI = 0;
        case 'FULL'
            debug = 1;
        case 'EXCESSIVE'
            debug = 1;
            doPlot = 1;
    end
end


if isfield(o,'METHOD')
    m = upper(o.METHOD);
    switch(m)
        case 'TENSOR'
            method = TENSOR;
        case 'NEWTON'
            method = NEWTON;
        case 'NEWTON0LBFGS'
            method = NEWTON0;
            cgSolve = 1;
        case 'NEWTON0'
            method = NEWTON0;
        case 'BFGS'
            method = BFGS;
        case 'LBFGS'
            method = LBFGS;
        case 'BB'
            method = BB;
        case 'CG'
            method = CG;
        case 'CSD'
            method = CSD;
        case 'SD'
            method = SD;
    end
end

c2 = 0.9;
LS_init = 0;
LS = 4;
Fref = 1;
Damped = 0;
% Method Specific Default Options if different than the above
if method == BB
    LS = 2;
    Fref = 10;
elseif method == CG
    c2 = 0.2;
    LS_init = 1;
elseif method == CSD
    c2 = 0.2;
    Fref = 10;
elseif method == SD
    LS = 2;
    LS_init = 1;
elseif method == BFGS
    Damped = 1;
end

maxFunEvals = getOpt(o,'MAXFUNEVALS',1000);
maxIter = getOpt(o,'MAXITER',500);
tolFun = getOpt(o,'TOLFUN',1e-5);
tolX = getOpt(o,'TOLX',1e-9);
corrections = getOpt(o,'CORR',100);
c1 = getOpt(o,'C1',1e-4);
c2 = getOpt(o,'C2',c2);
LS_init = getOpt(o,'LS_INIT',LS_init);
LS = getOpt(o,'LS',LS);
cgSolve = getOpt(o,'CGSOLVE',cgSolve);
SR1 = getOpt(o,'SR1',0);
cgUpdate = getOpt(o,'CGUPDATE',1);
initialHessType = getOpt(o,'INITIALHESSTYPE',1);
HessianModify = getOpt(o,'HESSIANMODIFY',0);
Fref = getOpt(o,'FREF',Fref);
useComplex = getOpt(o,'USECOMPLEX',0);
numDiff = getOpt(o,'NUMDIFF',0);
LS_saveHessianComp = getOpt(o,'LS_SAVEHESSIANCOMP',1);
DerivativeCheck = getOpt(o,'DERIVATIVECHECK',0);
Damped = getOpt(o,'DAMPED',Damped);
HvFunc = getOpt(o,'HVFUNC',[]);
bbType = getOpt(o,'BBTYPE',0);
cycle = getOpt(o,'CYCLE',3);
boundStepLength = getOpt(o,'BOUNDSTEPLENGTH',0);
HessianIter = getOpt(o,'HESSIANITER',1);
outputFcn = getOpt(o,'OUTPUTFCN',[]);
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

function [o] = toUpper(o)
if ~isempty(o)
    fn = fieldnames(o);
    for i = 1:length(fn)
        o = setfield(o,upper(fn{i}),getfield(o,fn{i}));
    end
end
end