function [Xtrain,ytrain,Xtest,ytest] = setupMnist(varargin)%binary, Ntrain, Ntest,full)
% Load mnist handwritten digit data
% Optional arguments [default in brackets]
% binary - if true, binarize around overall mean [false]
% ntrain - [60000]
% ntest - [10000]
% keepSparse - if true, do not cast to double [true]
% classes - specify which classes you want train/test data for [0:9]
%
% Xtrain will be ntrain*D, where D=784
% ytrain will be ntrain*1
% Xtest will be ntest*D, where D=784
% ytest will be ntest*1

% This file is from pmtk3.googlecode.com


[binary,Ntrain,Ntest,keepSparse,classes] = process_options(varargin,...
  'binary',false,'ntrain',60000,'ntest',10000,'keepSparse',true,'classes',0:9);
        
if nargout < 3, Ntest = 0; end

loadData('mnistAll');
% the datacase have already been shuffled 
% so we can safely take a prefix of the data
Xtrain = reshape(mnist.train_images(:,:,1:Ntrain),28*28,Ntrain)';
Xtest = reshape(mnist.test_images(:,:,1:Ntest),28*28,Ntest)';
ytrain = (mnist.train_labels);
ytest = (mnist.test_labels);
ytrain = ytrain(1:Ntrain);
ytest = ytest(1:Ntest);
clear mnist;
if(binary)
    mu = mean([Xtrain(:);Xtest(:)]);
    Xtrain = Xtrain >=mu;
    Xtest = Xtest >=mu;
end
ytrain = double(ytrain);
ytest  = double(ytest);

if(~keepSparse)
   Xtrain = double(Xtrain);
   Xtest  = double(Xtest);
end

if ~isequal(classes,0:9)
    Xtrain = Xtrain(ismember(ytrain,classes),:); 
    if numel(Ntest) > 0
       Xtest = Xtest(ismember(ytest,classes),:);
    end
end

end
