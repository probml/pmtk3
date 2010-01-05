function [d] = solveNewton(g,H,Hmodify,verbose)

nVars = size(H,1);

if nargin < 3 || Hmodify == 0
    [R,posDef] = chol(H);
    if posDef == 0
        d = -R\(R'\g);
    else
        H = H + eye(nVars)*max(0,1e-12 - min(real(eig(H))));
        d = -H\g;
    end
else
    [L D perm] = mcholC(H);
    d = zeros(nVars,1);
    d(perm) = -L' \ ((D.^-1).*(L \ g(perm)));
    
    if sum(abs(d)) > 1e5
        if verbose == 2
            fprintf('Step gone crazy, adjusting...\n');
        end
        [L D perm] = mcholC(H,1);
        d(perm) = -L' \ ((D.^-1).*(L \ g(perm)));
    end
end