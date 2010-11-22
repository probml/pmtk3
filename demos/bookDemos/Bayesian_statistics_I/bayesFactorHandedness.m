%% Bayes factor for handedness/ gender data

% This file is from pmtk3.googlecode.com

clear all
sfs = [1 2 3 4 5];
Nsf = length(sfs); BF10vsN = zeros(1,Nsf);
for i=1:Nsf
sf = sfs(i);
y1 = 9*sf; n1 = 52*sf; y2 = 4*sf; n2 = 48*sf;
%y1 = 1*sf; n1 = 50*sf; y2 = 25*sf; n2 = 50*sf;
N(i) = n1+n2;
alphas = [1 1];
logZ = betaln(alphas(1), alphas(2));
logmarglik0 = nchoosekln(n1+n2,y1+y2)...
  + betaln(alphas(1)+y1+y2, alphas(2)+(n1+n2-y1-y2)) -logZ;
logmarglik1 = (nchoosekln(n1,y1) + nchoosekln(n2,y2)) ...
  + betaln(alphas(1)+y1, alphas(2)+(n1-y1)) -logZ ...
  + betaln(alphas(1)+y2, alphas(2)+(n2-y2)) -logZ;
BF10vsN(i) = exp(logmarglik1 - logmarglik0);

% shortcut formula if alpha=1
BF10(i) = ( (1/(n1+1))*(1/(n2+1))) / (1/(n1+n2+1));
BF(i) = (n1+n2+1)/( (n1+1)*(n2+1) );
end
BF10vsN
BF10
BF
assert(approxeq(BF10, BF10vsN))
postNull = 1./(1+BF10vsN)


if 1
figure; plot(N, BF10vsN, 'o-', 'linewidth', 3);
xlabel('N'); ylabel('BF10')
%printPmtkFigure('BFhandedness')
end

