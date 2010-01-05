function stop = optimstore(x, optimValues, state)
% store history of optimization vlaues
global xhist fhist funcounthist
xhist = [xhist x];
fhist = [fhist optimValues.fval];
funcounthist = [funcounthist optimValues.funcount];
stop = false;

