%% DNA Sequence Demo
%

% This file is from pmtk3.googlecode.com

close all; clear all
setSeed(1);
Nseq = 10;
Nlocn = 15;
Nletters = 4;
Nmix = 4;
pfg = 0.30;

mixweights = [pfg/Nmix*ones(1,Nmix) 1-pfg]; % 5 states
z = sampleDiscrete(mixweights, 1, Nlocn);
alphas = 1*ones(Nletters,Nmix);
for i=1:Nmix
  alphas(i,i) = 20; % reflects purity
end
alphas(:,Nmix+1) = ones(Nletters, 1); % state 5 is background

theta = zeros(Nletters, Nlocn);
data = zeros(Nseq, Nlocn);
chars = ['a' 'c' 'g' 't' '-']';
for t=1:Nlocn
  theta(:,t) = dirichlet_sample(alphas(:,z(t)),1)';
  data(:,t) = sampleDiscrete(theta(:,t), Nseq, 1);
  dataStr(:,t) = chars(data(:,t));
end

for i=1:Nseq
  for t=1:Nlocn
    fprintf('%s ', dataStr(i,t));
  end
  fprintf('\n');
end

%% MLE
counts = zeros(4, Nlocn);
for c=1:4
   counts(c,:) = sum(data==c,1); % sum across sequences
end
thetaHat = counts/Nseq;
tmp = thetaHat; tmp(tmp==0) = 1; % log(1)=0
matrixEntropy = -sum(tmp .* log2(tmp), 1);
seqlogoPmtk(thetaHat)
printPmtkFigure('seqlogo')


