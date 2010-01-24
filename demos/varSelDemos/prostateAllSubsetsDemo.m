% Reproduce fig 3.5 on p56 of "Elements of statistical learning" 

clear all
load('prostate.mat') % from prostateDataMake
[n d] = size(Xtrain);
[w, mseTrain, mseTest, sz, members] =  allSubsetsRegression(Xtrain, ytrain, [], [], 0:d, 1);

figure(1);clf
plot(sz, mseTrain*n, '.');
hold on
for i=0:d
  ndx = find(sz==i);
  [bestScore(i+1) bestSet] = min(mseTrain(ndx));
end
plot(0:d, n*bestScore, 'ro-')
xlabel('subset size')
ylabel('RSS on training set')
title('all subsets on prostate cancer')
