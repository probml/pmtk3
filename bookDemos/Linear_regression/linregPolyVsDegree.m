%% Linear Regression with Polynomial Basis of different degrees
% based on code code by Romain Thibaux
% (Lecture 2 from http://www.cs.berkeley.edu/~asimma/294-fall06/)
%%

close all; clear all;
[xtrain, ytrain, xtest, ytestNoisefree, ytest] = polyDataMake('sampling','thibaux');


degs = 0:2:20;
Nm = length(degs);
mseTrain = zeros(1,Nm); mseTest = zeros(1,Nm);
for m=1:length(degs)
  deg = degs(m);
  pp = preprocessorCreate('rescaleX', true, 'poly', deg, 'addOnes', true);
  %addOnes = false;
  %Xtrain = rescaleData(degexpand(xtrain, deg, addOnes)); 
  %Xtest = rescaleData(degexpand(xtest, deg, addOnes));
  model = linregFit(xtrain, ytrain, 'preproc', pp);
  ypredTrain = linregPredict(model, xtrain);
  ypredTest = linregPredict(model, xtest);
  mseTrain(m) = mean((ytrain-ypredTrain).^2);
  mseTest(m) = mean((ytest-ypredTest).^2);
    
  if ismember(deg, [0, 2, 10, 14, 20])
    figure;
    scatter(xtrain,ytrain,'b','filled');
    hold on; 
    plot(xtest, ypredTest, 'k', 'linewidth', 3);
    hold off
    title(sprintf('degree %d', deg))
     set(gca,'ylim',[-10 15]);
     set(gca,'xlim',[-1 21]);
    if ismember(deg, 14)
      printPmtkFigure(sprintf('polyfitDemo%d', deg))
    end
  end
 
end

ndx = (degs<=16);
figure;
hold on
plot(degs(ndx), mseTrain(ndx), 'bs:', 'linewidth', 2, 'markersize', 12);
plot(degs(ndx), mseTest(ndx), 'rx-', 'linewidth', 2, 'markersize', 12);
xlabel('degree')
ylabel('mse')
legend('train', 'test')
printPmtkFigure('linregPolyVsDegreeUcurve')
placeFigures;

