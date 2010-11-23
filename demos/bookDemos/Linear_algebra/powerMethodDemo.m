%% Power Method Demo
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0);

%C = randpd(3);

n = 10; d = 3;
X = randn(n,d);
%C = (1/n)*X'*X;
C = X'*X;

[lam, u] = powerMethod(C);

[uAll,lamAll] = eig(C);
lamAll = diag(lamAll);
[junk, ndx] = sort(lamAll, 'descend');
u1 = uAll(:,ndx(1));
lam1 = lamAll(ndx(1));

assert(approxeq(lam, lam1))
assert(approxeq(abs(u), abs(u1)))
