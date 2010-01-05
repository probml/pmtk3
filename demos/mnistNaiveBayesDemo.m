if 0
% naive Bayes classifier for binary MNIST digits
%Ntrain=5000, 83 errors in 500, rate = 0.166

load('C:/kmurphy/Data/mnistALL') % already randomly shuffled across classes
% train_images: [28x28x60000 uint8]
% test_images: [28x28x10000 uint8]
% train_labels: [60000x1 uint8]
% test_labels: [10000x1 uint8]

% reshape to be size Ntrain*Ndims
ytrain = mnist.train_labels;
ytest = mnist.test_labels;
Xtrain = reshape(mnist.train_images, [28*28 60000])';
Xtest = reshape(mnist.test_images, [28*28 10000])';

% Binarize
for c=1:10
   digit=c-1;
   ndx = find(ytrain==digit);
   mu = mean(Xtrain(ndx,:));
   Xtrain(ndx,:) = Xtrain(ndx,:) > repmat(mu,length(ndx),1);
   ndx = find(ytest==digit);
   Xtest(ndx,:) = Xtest(ndx,:) > repmat(mu,length(ndx),1);
end
% save space
clear mnist
Xtrain = logical(Xtrain);
Xtest = logical(Xtest);

end

trainSize = [1000 5000 10000 30000 60000];
%trainSize = [500];
classes = 0:9;
Nclasses = 10;
pOn = zeros(c, 28*28); % probability bit is on
for trial=1:length(trainSize)
   Ntrain = trainSize(trial);
   fprintf('training with %d examples\n', Ntrain);
   
   % Train 
   for digit=classes
      c = digit+1;
      ndx = (ytrain(1:Ntrain)==digit);
      Xtr = Xtrain(ndx,:);
      Non = sum( Xtr==1, 1);
      Noff = sum( Xtr==0, 1);
      a = 1; b = 1; % Laplace smoothing
      pOn(c,:) = (Non + a) ./ (Non + Noff + a + b); % posterior mean
      Nclass(c) = length(ndx);
   end
   classPrior = normalize(Nclass+1)
   logPrior = log(classPrior);
   
   % Test
   Ntest = 1000; % no need to use them all, already shuffled
   ndxError = []; % stores indices of misclassified examples
   classConf = zeros(Nclasses, Nclasses);
   loglik = zeros(1,Nclasses);
   fprintf('testing with %d examples\n', Ntest);
   for i=1:Ntest
      % classify
      for c=1:Nclasses
         theta = pOn(c,:);
         bitmask = Xtest(i,:);
         loglik(c) = sum(bitmask .* log(theta) + (1-bitmask) .* log(1-theta));
      end
      yhat = argmax(loglik + logPrior)-1;
      y = ytest(i);
      if yhat ~= y
         ndxError = [ndxError i];
         if 0
            fprintf('classying %d of %d, ytrue = %d, yhat = %d\n', ...
               i, Ntest, y, yhat);
            figure(1);clf
            img = reshape(Xtest(i,:), [28 28]);
            imagesc(img);
            colormap(gray)
            title(sprintf('testcase %d, ytrue = %d, yhat = %d', i, y, yhat));
            pause(0.1)
         end
      end
      classConf(y+1,yhat+1) = classConf(y+1,yhat+1)+1;
   end
   nerr = length(ndxError);
   fprintf('Ntrain=%d, %d errors in %d, rate = %5.3f\n', ...
      Ntrain, nerr, Ntest, nerr/Ntest);
   errorRate(trial) = nerr/Ntest;
   classConf = classConf/Ntest;
   classConfMat{trial} = classConf;
   
  
   
end

figure;
plot(trainSize, errorRate, 'o-', 'linewidth', 3, 'markersize', 10)
xlabel('training set size')
ylabel('error rate')
title('Naive bayes on binarized MNIST digits')
printPmtkFigure('mnistNaiveBayesErrVsN')


if 0
% Latex formatting
classConf = classConfMat{end};
for c=1:10
   fprintf('%3.2f & ', 100*classConf(c,1:9));
   fprintf('%3.2f \\\\ \n', 100*classConf(c,10));
   %fprintf('\n');
end
end

classConf = classConfMat{end};
C=setdiag(classConf,0);figure;imagesc(C);colorbar
set(gca,'yticklabel',0:9)
set(gca,'xtick',1:10,'xticklabel',0:9)
title('class confusion matrix')


for i=[116] % ndxError(:)'
   figure(1);clf
   img = reshape(Xtest(i,:), [28 28]);
   imagesc(img);
   colormap(gray)
   y = ytest(i);
   % classify
   for c=1:Nclasses
      theta = pOn(c,:);
      bitmask = Xtest(i,:);
      loglik(c) = sum(bitmask .* log(theta) + (1-bitmask) .* log(1-theta));
   end
   yhat = argmax(loglik)-1;
   title(sprintf('testcase %d, ytrue = %d, yhat = %d', i, y, yhat));
   pause;
end


