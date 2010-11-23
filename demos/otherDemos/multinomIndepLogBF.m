%% Multinomial Bayes Factor demo
%
%%

% This file is from pmtk3.googlecode.com

function multinomIndepLogBF()
counts = [...
    15 29 14;
    46 83 56];
[logBF]       = helper(counts)
pIndepOverDep = exp(logBF)
end

function [logBF] = helper(counts)
Njk = counts;
Nj = sum(counts,2);
Nk = sum(counts,1);
N = sum(counts(:));
[J,K] = size(counts);
alphajk = ones(J,K);
%alphaj = ones(J,1);
%alphak = ones(1,K);
alphaj =  sum(alphajk, 2);
alphak = sum(alphajk, 1);

logBF = gammaln(sum(alphajk(:))) - gammaln(N + sum(alphajk(:))) ...
    + sum(gammaln(Nj + alphaj)) - sum(gammaln(alphaj)) ...
    + sum(gammaln(Nk + alphak)) - sum(gammaln(alphak)) ...
    + sum(gammaln(alphajk(:))) - sum(gammaln(Njk(:) + alphajk(:)));

logBF2 = logbeta(Nj+alphaj) + logbeta(Nk + alphak) + logbeta(alphajk(:))...
    - logbeta(alphaj) - logbeta(alphak) - logbeta(Njk(:) + alphajk(:));
assert(approxeq(logBF, logBF2))


end

function L = logbeta(alpha)
L = sum(gammaln(alpha)) - gammaln(sum(alpha));
end

