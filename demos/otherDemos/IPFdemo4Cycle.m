%% Fit loopy MRF 1-2-3-1 using iterative proportional fitting
%
%%

% This file is from pmtk3.googlecode.com

clqs = {[1 2], [2 3], [1 3]};
NC = length(clqs);
N = 3;

% Some count data
C = reshape([53 414 11 37 0 16 4 139], [2 2 2]);
C = normalize(C);
Cpot = tabularFactorCreate(C, 1:N);
counts = cell(1, NC);
for c=1:NC
    counts{c} = tabularFactorMarginalize(Cpot, clqs{c});
end

% Initial guess is all 1's
pots = cell(1, NC);
for c=1:NC
    pots{c} = tabularFactorCreate(2*ones(2, 2), clqs{c});
end
converged = 0;
iter = 0;
thresh = 1e-3; % convergence threshold
while ~converged
    converged = 1;
    potsOld = pots;
    iter = iter + 1;
    fprintf('iter %d\n', iter);
    for c=1:NC
        J = tabularFactorMultiply(pots{:});
        Mc = tabularFactorMarginalize(J, clqs{c});
        pots{c}.T = pots{c}.T .* (counts{c}.T ./ Mc.T);
        if ~approxeq(pots{c}.T, potsOld{c}.T, thresh)
            converged = 0;
        end
        fprintf('c=%d\n', c)
    end
end

J = tabularFactorMultiply(pots{:});
for c=1:NC
    Mc = tabularFactorMarginalize(J, clqs{c});
    assert(approxeq(counts{c}.T, Mc.T))
end

