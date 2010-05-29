function stop = optimstore(x, optimValues, state)
% store history of optimization vlaues
global xhist fhist funcounthist
xhist = [xhist x];
fhist = [fhist optimValues.fval];
if isfield(optimValues, 'funcount')
    funcount = optimValues.funcount;
elseif isfileld(optimValues, 'funccount')
    funcount = optimValues.funccount;
else
    funcount = NaN;  
end
funcounthist = [funcounthist funcount];
stop = false;

end