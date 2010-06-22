%% Compare various optimizers on a simple logistic regression problem

loadData('mnistAll');
if 0
  % test on all data- 255 seconds, 3.09% error
  trainndx = 1:60000; testndx =  1:10000;
else
  % test on subset - 8 seconds, 3.80% error
  trainndx = 1:60000; 
  testndx =  1:1000; 
end
ntrain = length(trainndx);
ntest = length(testndx);
Xtrain = double(reshape(mnist.train_images(:,:,trainndx),28*28,ntrain)');
Xtest  = double(reshape(mnist.test_images(:,:,testndx),28*28,ntest)');

if 0 
  % matrix is real-valued but has many zeros due to black boundary
  % so we make it sparse to save space - does not work in octave
  Xtrain = sparse(Xtrain);
  Xtest = sparse(Xtest);
end

ytrain = (mnist.train_labels(trainndx));
ytest  = (mnist.test_labels(testndx));
clear mnist trainndx testndx; % save space
