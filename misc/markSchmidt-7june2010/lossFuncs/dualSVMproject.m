function [proj] = dualSVMproject(alpha,nPositive)

nVars = length(alpha);
alphaPlus = alpha(1:nPositive);
alphaMinus = alpha(nPositive+1:end);

nPlus = length(alphaPlus);
nMinus = length(alphaMinus);
a = [ones(nPlus,1);-ones(nMinus,1)];

[sortedPlus,sortedIndPlus] = sort(alphaPlus,'descend');
[sortedMinus,sortedIndMinus] = sort(alphaMinus,'descend');
minVal = inf;
proj = [];
for i = 0:nPlus
    for j = 0:nMinus
        cand = zeros(nVars,1);
        if i > 0
            indPlus = sortedIndPlus(1:i);
        else
            indPlus = [];
        end
        if j > 0
            indMinus = nPlus+sortedIndMinus(1:j);
        else
            indMinus = [];
        end

        ind = [indPlus;indMinus];
        cand(ind) = alpha(ind) - (a(ind)'*alpha(ind))*a(ind)/(a(ind)'*a(ind));

        if all(cand >= 0) && abs(sum(cand(1:nPlus)) - sum(cand(nPlus+1:end))) < 1e-4
            if norm(cand-alpha) < minVal
                proj = cand;
            end
        end
    end
end