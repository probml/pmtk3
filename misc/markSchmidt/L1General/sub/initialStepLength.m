function [t,f_prev] = initialStepLength(i,adjustStep,order,f,g,gtd,t,f_prev)

if i == 1 || adjustStep == 0
    t = 1;
else
    t = min(1,2*(f-f_prev)/gtd);
end

if i == 1 && order < 2
    t = min(1,1/sum(abs(g)));
end

f_prev = f;