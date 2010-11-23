% Demo of ICA

% This file is from pmtk3.googlecode.com


[sigTrue,mixedsig]=demosig(); % create signal using fast ICA package
[icasig, A, W] = fastica(mixedsig);
X = mixedsig';
[B, Z, evals, Xrecon, mu] = pcaPmtk(X, 4);
pcasig = Z';

figure;
for i=1:4
  subplot(4,1,i); plot(sigTrue(i,:));
end
suptitle('truth')
printPmtkFigure('icaTruth')

figure;
for i=1:4
  subplot(4,1,i); plot(mixedsig(i,:));
end
suptitle('observed signals')
printPmtkFigure('icaObs')

figure;
for i=1:4
  subplot(4,1,i); plot(icasig(i,:));
end
suptitle('ICA estimate')
printPmtkFigure('icaIca')

figure;
for i=1:4
  subplot(4,1,i); plot(pcasig(i,:));
end
suptitle('PCA estimate')
printPmtkFigure('icaPca')

