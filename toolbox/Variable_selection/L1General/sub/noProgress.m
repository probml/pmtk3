function [x] = noProgress(td,f,f_old,optTol,verbose)

x = 0;
if abs(f-f_old) < optTol
    x = 1;
    if verbose
        fprintf('Change in Objective below optTol\n');
    end
elseif sum(abs(td)) < optTol
    x = 1;
    if verbose
        fprintf('Step Size below optTol\n');
    end
end