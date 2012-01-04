function stop = optimstore(x, optimValues, state)
% store history of optimization vlaues

 
% This file is from pmtk3.googlecode.com

global xhist fhist funcounthist
xhist = [xhist x];
fhist = [fhist optimValues.fval];
if isfield(optimValues, 'funcount')
    funcount = optimValues.funcount;
elseif isfield(optimValues, 'funccount')
    funcount = optimValues.funccount;
else
    funcount = NaN;  
end
funcounthist = [funcounthist funcount];
stop = false;

end
