function [model, errors] = rbmFit(X, numhid, varargin)
% Fit a bernoulli-bernoulli RBM to binary data
% optionally with class labels
%
%INPUTS: 
%X              ... N*d matrix, entries in [0,1]
%numhid         ... number of hidden units
%
%
%OPTIONAL INPUTS (specified as name value pairs *or in struct*)
%y              ... N*1 class labels, in {1..C} or []
%method         ... CD or SML 
%eta            ... learning rate
%momentum       ... momentum for smoothness amd to prevent overfitting
%               ... NOTE: momentum is not recommended with SML
%maxepoch       ... # of epochs: each is a full pass through train data
%avglast        ... how many epochs before maxepoch to start averaging
%               ... before. Procedure suggested for faster convergence by
%               ... Kevin Swersky in his MSc thesis
%penalty        ... L2 weight decay strength
%weightdecay    ... A boolean flag. When set to true, the weights are
%               ... Decayed linearly from penalty->0.1*penalty in epochs
%batchsize      ... The number of training instances per batch
%verbose        ... For printing progress
%anneal         ... Flag. If set true, the penalty is annealed linearly
%               ... through epochs to 10% of its original value
%
%OUTPUTS:
%model.W        ... The weights of the connections
%model.b        ... The biases of the hidden layer
%model.c        ... The biases of the visible layer
%model.Wc       ... The weights on labels layer
%model.cc       ... The biases on labels layer
%
%errors         ... The errors in reconstruction at every epoch

% This file is from pmtk3.googlecode.com


%PMTKauthor Andrej Karpathy, Kevin Swersky, Ruslan Salakhutdinov, Geoff Hinton
%PMTKdata April 2010
%PMTKmodified Kevin Murphy


%Process options
args= prepareArgs(varargin);
[   y             ...
  method        ...
  eta           ...
  momentum      ...
  maxepoch      ...
  avglast       ...
  penalty       ...
  batchsize     ...
  verbose       ...
  anneal        ...
  ] = process_options(args    , ...
  'y'             , [], ...
  'method'        ,  'CD'     , ...
  'eta'           ,  0.1      , ...
  'momentum'      ,  0.5      , ...
  'maxepoch'      ,  50       , ...
  'avglast'       ,  5        , ...
  'penalty'       , 2e-4      , ...
  'batchsize'     , 100       , ...
  'verbose'       , false     , ...
  'anneal'        , false);

avgstart = maxepoch - avglast;
oldpenalty= penalty;
[N,d]=size(X);

if (verbose)
  fprintf('Preprocessing data...\n')
end

if isempty(y)
  supervised = false;
else
  supervised = true;
  %Create targets: 1-of-k encodings for each discrete label
  u = unique(y);
  nclasses = numel(u);
  targets = dummyEncoding(y, nclasses);
  %targets= zeros(N, nclasses);
  %for i=1:length(u)
  %  targets(y==u(i),i)=1;
  %end
end

%% Create batches
numbatches= ceil(N/batchsize);
groups= repmat(1:numbatches, 1, batchsize);
groups= groups(1:N);
groups = groups(randperm(N));
for i=1:numbatches
  batchdata{i}= X(groups==i,:);
  if supervised, batchtargets{i}= targets(groups==i,:); end
end

%% fit RBM
numcases=N;
numdims=d;
W = 0.1*randn(numdims,numhid);
c = zeros(1,numdims);
b = zeros(1,numhid);
if supervised
  numclasses= length(u);
  Wc = 0.1*randn(numclasses,numhid);
  cc = zeros(1,numclasses);
else
  Wc = 0; cc = 0; numclasses = 0;
end
ph = zeros(numcases,numhid);
nh = zeros(numcases,numhid);
phstates = zeros(numcases,numhid);
nhstates = zeros(numcases,numhid);
negdata = zeros(numcases,numdims);
negdatastates = zeros(numcases,numdims);
Winc  = zeros(numdims,numhid);
binc = zeros(1,numhid);
cinc = zeros(1,numdims);
if supervised
  Wcinc = zeros(numclasses,numhid);
  ccinc = zeros(1,numclasses);
end
Wavg = W;
bavg = b;
cavg = c;
if supervised
  Wcavg = Wc;
  ccavg = cc;
end
t = 1;
errors=zeros(1,maxepoch);

for epoch = 1:maxepoch
  
  errsum=0;
  if (anneal)
    penalty= oldpenalty - 0.9*epoch/maxepoch*oldpenalty;
  end
  
  for batch = 1:numbatches
    [numcases numdims]=size(batchdata{batch});
    data = batchdata{batch};
    if supervised
      classes = batchtargets{batch};
    else
      classes = 0;
    end
    
    %go up
    ph = sigmoid(data*W + classes*Wc + repmat(b,numcases,1));
    phstates = ph > rand(numcases,numhid);
    if (isequal(method,'SML'))
      if (epoch == 1 && batch == 1)
        nhstates = phstates;
      end
    elseif (isequal(method,'CD'))
      nhstates = phstates;
    end
    
    %go down
    negdata = sigmoid(nhstates*W' + repmat(c,numcases,1));
    negdatastates = negdata > rand(numcases,numdims);
    if supervised
      negclasses = softmaxPmtk(nhstates*Wc' + repmat(cc,numcases,1));
      negclassesstates = softmax_sample(negclasses);
    else
      negclassesstates = 0;
    end
    
    %go up one more time
    nh = sigmoid(negdatastates*W + negclassesstates*Wc + ...
      repmat(b,numcases,1));
    nhstates = nh > rand(numcases,numhid);
    
    %update weights and biases
    dW = (data'*ph - negdatastates'*nh);
    dc = sum(data) - sum(negdatastates);
    db = sum(ph) - sum(nh);
    if supervised
      dWc = (classes'*ph - negclassesstates'*nh);
      dcc = sum(classes) - sum(negclassesstates);
    end
    
    Winc = momentum*Winc + eta*(dW/numcases - penalty*W);
    binc = momentum*binc + eta*(db/numcases);
    cinc = momentum*cinc + eta*(dc/numcases);
    if supervised
      Wcinc = momentum*Wcinc + eta*(dWc/numcases - penalty*Wc);
      ccinc = momentum*ccinc + eta*(dcc/numcases);
    end
    
    W = W + Winc;
    b = b + binc;
    c = c + cinc;
    if supervised
      Wc = Wc + Wcinc;
      cc = cc + ccinc;
    end
    
    if (epoch > avgstart)
      %apply averaging
      Wavg = Wavg - (1/t)*(Wavg - W);
      cavg = cavg - (1/t)*(cavg - c);
      bavg = bavg - (1/t)*(bavg - b);
      if supervised
        Wcavg = Wcavg - (1/t)*(Wcavg - Wc);
        ccavg = ccavg - (1/t)*(ccavg - cc);
      end
      t = t+1;
    else
      Wavg = W;
      bavg = b;
      cavg = c;
      if supervised
        Wcavg = Wc;
        ccavg = cc;
      end
    end
    
    %accumulate reconstruction error
    err= sum(sum( (data-negdata).^2 ));
    errsum = err + errsum;
  end
  
  errors(epoch)= errsum;
  if (verbose)
    fprintf('Ended epoch %i/%i, mean reconsruction error is %f\n', ...
      epoch, maxepoch, errsum/N);
  end
end

model.W = Wavg;
model.b = bavg;
model.c = cavg;
model.nparams = numel(model.W) + numel(model.b) + numel(model.c); 
if supervised
  model.Wc = Wcavg;
  model.cc = ccavg;
  model.nparams = model.nparams + numel(model.Wc) + numel(model.cc);
end
model.type= 'BB';
model.modelType = 'rbm';

end
