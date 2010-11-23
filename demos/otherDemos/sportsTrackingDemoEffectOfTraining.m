% evaluate performance as funciton of training set size
% using hard labeling

% PMTKinprogress

% This file is from pmtk3.googlecode.com


function sportsTrackingDemoEffectOfTraining()


folder = 'C:\kmurphy\People\JoAnneTing\sports';
setSeed(2);

Nplayers = 3;
noiseLevelLinkage = 0;
pcEmptyFrames = 0.2;

%Nmix = [1*ones(1,Nplayers) 1]; % easy 
Nmix = [1*ones(1,Nplayers) 2]; % medium
%Nmix = [2*ones(1,Nplayers) 5]; % hard
obsNoiseLevel = 0.1;
nfeatures = 3;

trainSizes = [10 20 50];
engines = {'jtree'};

opts.useMutex = 1;
opts.useTemporal = 1;
opts.temporalStrength = 1;
opts.mutexStrength = 1;


%% Make data



[obsModel] = mkAppearanceModel(Nplayers, obsNoiseLevel, Nmix, nfeatures);
cancolors = mkCanonicalColors(obsModel);
 
dataTest = generateData(30, Nplayers, obsModel, cancolors, ...
  noiseLevelLinkage, pcEmptyFrames);


for sizeTrial=1:numel(trainSizes)
  Ntrain = trainSizes(sizeTrial);
  dataTrainSets{sizeTrial} = generateData(Ntrain, Nplayers, obsModel, cancolors, ...
    noiseLevelLinkage, pcEmptyFrames);
end



%% Plot data
drawData(dataTest);
%set(gcf, 'name', 'test data')
suptitle('test data')
print(gcf, '-dpng', fullfile(folder, 'sportsTestData.png'))

drawBel(dataTest.trueBel, dataTest);
set(gcf, 'name', 'truth')
suptitle('truth')
print(gcf, '-dpng', fullfile(folder, 'sportsTrueBel.png'))

if 1
% apply rnd model to data with soft labels
% to see how well we can decode the identitities
% while ignoring appearance info (since obsParams are [])
opts.infEngine = 'jtree';
[bel, ll, model] = inferBel([], dataTest, opts, 'soft');
drawBel(bel, dataTest);
[loss, errRate] =  evalPerf(bel, dataTest);
lossSoftOracle = loss;
errSoftOracle = errRate;
str = sprintf('iid using soft labels (no appearance). KL %5.3f, errrate %5.3f', loss, errRate)
set(gcf, 'name', str)
suptitle(str)
print(gcf, '-dpng', fullfile(folder, 'sportsBelSoftOracle.png'))
end



%% Main body
for engineTrial=1:numel(engines)
  infEngine = engines{engineTrial};
  for sizeTrial=1:numel(trainSizes)
    Ntrain = trainSizes(sizeTrial);
     dataTrain = dataTrainSets{sizeTrial};

fprintf('\n\nNtrain=%d, engine=%s\n', Ntrain, infEngine);
opts.infEngine = infEngine;


if 1
% iid training  on hard labels - 
% same as GM training with unique labels but much faster
% This gives an upper bound on performance of soft training.
fprintf('iid hard training\n');
ess.X = dataTrain.appearanceVec'; % X(cases,features)
ess.bel = dataTrain.trueBel;
modelHard = mstep([], ess); % learns modelHard.obsParams

% test
[bel] = inferBel(modelHard, dataTest, opts, 'none');
drawBel(bel, dataTest);
[loss, errRate] =  evalPerf(bel, dataTest);
hardLoss(sizeTrial, engineTrial) = loss;
hardErr(sizeTrial, engineTrial) = errRate;
str = sprintf('train hard %d. Test KL %5.3f, errrate %5.3f', Ntrain, loss, errRate)
set(gcf, 'name', str);
suptitle(str)
print(gcf, '-dpng', fullfile(folder, sprintf('sportsBelHard%d.png',Ntrain)))
end

if 0 
% test with ablated iid model
tmpOpts = opts; tmpOpts.useMutex = 0; tmpOpts.useTemporal = 0;
[bel] = inferBel(modelHard, dataTest, tmpOpts, 'none');
drawBel(bel, dataTest);
[loss, errRate] =  evalPerf(bel, dataTest);
hardLossIID(sizeTrial, engineTrial) = loss;
hardErrIID(sizeTrial, engineTrial) = errRate;
str = sprintf('train hard %d. Test iid KL %5.3f, errrate %5.3f', Ntrain, loss, errRate)
set(gcf, 'name', str);
suptitle(str)
print(gcf, '-dpng', fullfile(folder, sprintf('sportsBelHardIID%d.png',Ntrain)))
end




if 1
% train up a model on soft labels
fprintf('soft training\n');
tic
[modelSoft] = fitModel(dataTrain, opts, 'soft');
trainTime = toc
tic
bel = inferBel(modelSoft, dataTest, opts, 'none');
testTime = toc
%printBel(bel, dataTrain)
drawBel(bel, dataTest);
[loss, errRate] =  evalPerf(bel, dataTest);
softLoss(sizeTrial, engineTrial) = loss;
softErr(sizeTrial, engineTrial) = errRate;
str = sprintf('train soft %d. Test KL %5.3f, errrate %5.3f, train time %5.3f', ...
  Ntrain, loss, errRate, trainTime)
set(gcf, 'name', str);
suptitle(str)
print(gcf, '-dpng', fullfile(folder, sprintf('sportsBelSoft%d.png',Ntrain)))
else
  softLoss = [];
end

end % sizeTrial

end % engineTrial


figure; hold on
plot(trainSizes, hardLoss, 'o-');
plot(trainSizes, softLoss, 'x:r');
%plot(trainSizes, hardLossIID, 'x:r');
horizontalLine(lossSoftOracle, 'color', 'k');
xlabel('training size');
title('KL')
%legend('gm hard', 'iid hard')
legend('hard', 'soft')
print(gcf, '-dpng', fullfile(folder, sprintf('sportsKL.png')))

figure; hold on
plot(trainSizes, hardErr, 'o-');
plot(trainSizes, softErr, 'x:r');
%plot(trainSizes, hardErrIID, 'x:r');
horizontalLine(errSoftOracle, 'color', 'k');
xlabel('training size');
title('Error rate')
%legend('gm', 'iid')
legend('hard', 'soft')
print(gcf, '-dpng', fullfile(folder, sprintf('sportsErr.png')))



end % function

function model = modelCreate(data, opts, labelType, obsParams)
% create graph and pots for MRF for a particular sequence
% When the observation CPD params change,
% we need to update nodepots
[D T] = size(data.appearanceVec);
if nargin < 4 || isempty(obsParams)
  % weight matrix for logreg: one column per state
  %obsParams = 0.1*randn(D+1,data.Nplayers);
  obsParams = zeros(D+1,data.Nplayers);
end
switch lower(opts.infEngine)
  case 'trwbp'
    infEngine = 'libdai';
    infEngArgs = {'TRWBP', '[updates=SEQFIX,tol=1e-3,maxiter=1000,logdomain=0,nrtrees=0]'};
  case 'jtree'
    infEngine = 'jtree';
    infEngArgs = {};
end
G = mkGraph(data, opts);
[edgePots, edgePotPointers] = mkEdgePots(data, opts, G);
% softEvLabels(:,j) = distribution for node j given labels
softEvLabels = mkSoftEvidenceFromLabels(data, labelType);
% softEvObs(:,j) = distribution for node j given data and params
softEvObs = mkSoftEvidenceFromObs(data,  obsParams);
softEv = softEvLabels .* softEvObs;
Nnodes = size(G,1);
Nstates = data.Nplayers;
softEvCell = mat2cell(softEv, Nstates, ones(1,Nnodes));
model.mrf     = mrfCreate(G, 'nodePots', softEvCell, ...
  'edgePots', edgePots, 'edgePotPointers', edgePotPointers,... 
    'infEngine', infEngine, 'infEngArgs', infEngArgs);
 model.obsParams = obsParams;
 model.softEvLabels = softEvLabels;
 model.softEvObs = softEvObs;
end

function [bel, ll, model] = inferBel(model, data, opts, labelType)
% We create a fresh model just for this data sequence
% However we reuse any observation paramters
if isempty(model)
  obsParams = [];
else
  obsParams = model.obsParams;
end
model = modelCreate(data, opts, labelType, obsParams);
[belTF, ll] = mrfInferNodes(model.mrf);
bel = tfMarg2Mat(belTF);
end


function [model] = fitModel(data, opts, labelType, EMargs)
if nargin < 4, EMargs = {'verbose', true}; end
model = modelCreate(data, opts, labelType);
data.labelType = labelType;
data.opts = opts;
[model, loglikHist] = emAlgo(model, data, @initFn, @estep, @mstep, ...
  'plotFn', [], EMargs{:}); %#ok
end

function plotfn(model, data, ess, ll, iter) %#ok
% Plot belief state after each E step
drawBel(ess.bel, data);
str = sprintf('iter=%d, ll=%5.3f', iter, ll);
set(gcf, 'name', str)
end

function model = initFn(model, data, r) %#ok
[D T] = size(data.appearanceVec);
% weight matrix for logreg: one column per state
model.obsParams = 0.1*randn(D+1,data.Nplayers);
end

function [ess,ll] = estep(model, data)
[ess.bel, ll] = inferBel(model, data, data.opts, data.labelType);
ess.X = data.appearanceVec'; % X(cases,features)
end

function model = mstep(model, ess)
N = size(ess.X,1);
X = [ones(N,1) ess.X];
y = ess.bel'; % y(cases, states) soft dummy encoding
cpd = logregFit(X, y, 'preproc', [], 'lambda', 0.01);
model.obsParams  = cpd.w;
end


function softEvObs = mkSoftEvidenceFromObs(data,  obsParams)
% Just evaluate logistic regression on data
% softEvObs(:,k) 
X = data.appearanceVec'; % X is N*D
N = size(X,1);
X = [ones(N,1) X];
W = obsParams;
prob = softmaxPmtk(X*W); % N*K
softEvObs = prob';
end

function softEvLabels = mkSoftEvidenceFromLabels(data, labelType)
% softEvLabels(k,j) = likelihood player k is  present at node j
% Does not need to be normalized
Nframes = numel(data.present);
Nnodes = sum(data.numPresent);
Nplayers = data.Nplayers;
if strcmpi(labelType, 'none')
  softEvLabels = ones(Nplayers, Nnodes);
  return;
end
softEvLabels = zeros(Nplayers, Nnodes);
for t=1:Nframes
  for i=1:numel(data.present{t})
    switch labelType
      case 'soft',
        ev = zeros(Nplayers,1);
        ev(data.present{t}) = 1;
      case 'unique',
        ev = zeros(Nplayers,1);
        ev(data.present{t}(i)) = 1; % delta fn
      case 'none',
        ev = ones(Nplayers,1);
    end
    j = data.node2dTo1d(t, i);
    softEvLabels(:,j) = ev;
  end
end
end




function [edgePots, edgePotPointers] = mkEdgePots(data, opts, G)
  useTemporal = opts.useTemporal;
  useMutex = opts.useMutex;
Nplayers = data.Nplayers;
% hard constraint that identity must be constant over time
%edgePotTemp = eye(Nplayers, Nplayers); 
% we use a soft constraint because of possible
% linking errors
edgePotTemp = softeye(Nplayers, opts.temporalStrength);

% hard constraint that 2 nodes cannot share same identity
edgePotMutex = opts.mutexStrength*ones(Nplayers, Nplayers);
edgePotMutex = setdiag(edgePotMutex, 0);
edgePotPointers = [];

if ~useTemporal && ~useMutex, edgePots = []; end
if useTemporal  && ~useMutex , edgePots = edgePotTemp; end
if useTemporal  && useMutex
  edgePots = {edgePotTemp, edgePotMutex};
  % figure out type of each edge and associate it
  % with the corresponding potential
  edges = find(tril(G));
  for n=1:numel(edges)
    [src, destn] = ind2sub(size(G), edges(n));
    ndx1  = data.node1dTo2d(src, :); % [t i]
    ndx2 = data.node1dTo2d(destn, :);
    if ndx1(1)==ndx2(1) % equal time stamps, so mutex edge
      edgePotPointers(n) = 2;
    else % temporal edge
      edgePotPointers(n) = 1;
    end
  end
end
end


function G = mkGraph(data, opts)
Nframes = numel(data.present);
Nnodes = sum(data.numPresent); % num detections
G = zeros(Nnodes, Nnodes); 
if opts.useTemporal
  for t=1:Nframes-1
    for i = 1:data.numPresent(t)  % i,j index detections not players
      %j = data.succ{t}(i); % successor
      j = data.noisysucc{t}(i); % successor
      if ~isnan(j)
        srcNode = data.node2dTo1d(t, i);
        destNode = data.node2dTo1d(t+1, j);
        G(srcNode, destNode) = 1;
      end
    end
  end
end
if opts.useMutex
   for t=1:Nframes
    for i = 1:data.numPresent(t) 
      for j=1:data.numPresent(t) 
        if i==j, continue; end
        srcNode = data.node2dTo1d(t, i);
        destNode = data.node2dTo1d(t, j);
        G(srcNode, destNode) = 1;
      end
    end
   end
end
G = mkSymmetric(G);
end

  


function status = mkVisibilityStatus(Nplayers, Nframes)
% Make an hmm which controls visibility of players
% states = identifiable (unique color - eg frontal view),
%  unidentifiable (ambiguous color),
%  absent (not in view)
id = 1; unid = 2; absent = 3;
T = zeros(3,3);
T(id,id) = 0.2;
T(id, unid) = 0.8;

T(unid, unid) = 0.5;
T(unid, id) = 0.2;
T(unid, absent) = 0.3;

T(absent, absent) = 0.1; %0.2; % 0.2 is easy
T(absent, unid) = 0.9; % 0.8;
assert(approxeq(T, mkStochastic(T)))
initStateDist = [1/3 1/3 1/3];
markovModelForVisStatus = markovCreate(initStateDist, T);
% visibility status is just used internally to decide
% color of player

% we sample the status of each player independently
status = markovSample(markovModelForVisStatus, Nframes, Nplayers);
end


function data = generateData(Nframes, Nplayers, obsModel, cancolor, noiseLevelLinkage, pcMissing)
% Output: data is a struct with these fields
% appearanceVec(:,d) = feature vector for d'th detection
% colorVec(:,d) = [r g b] for visualization only
% frontalShot(d) = 1 if this is a frontal (unique) view
% present{t} = [list of player ids present - in order of detection]
% succ{t}(i) = successor of detection i, or NaN if none
% numPresent(t) = numel(present{t})
% isPresent(t,p) = 1 if player p is present in frame t
% truth(d) = identity of d'th detection

status = mkVisibilityStatus(Nplayers, Nframes);
id = 1; unid = 2; absent = 3;
for t=1:Nframes
  flip = rand(1,1)<pcMissing;
  if flip
    status(:,t) = absent;
  end
end

% we mask out a certain fraction
% of the frames, forcing all players to be absent.
% This will break long chains and make inference harder.

overallCount = 1;
isPresent = true(Nframes, Nplayers);
appearanceVec = [];
frontalShot = false;
for t=1:Nframes
  frameCount = 1; % counts number of detections per frame
  for p=1:Nplayers
    % frameCount is the 'local' number for player i
    % skip absent players
    if status(p,t)==absent
      isPresent(t,p) = false;
      continue;
    end 
    if status(p,t)==unid
      modelNdx = Nplayers+1;
    else
      frontalShot(overallCount) = true;
      modelNdx = p;
    end
    [x,q] = mixModelSample(obsModel{modelNdx}, 1);
    appearanceVec(:, overallCount) = x;
    colorVec(:, overallCount) = cancolor{modelNdx}{q};
    trueId(t, frameCount) = p;
    truth(overallCount) = p;
    node2dTo1d(t,frameCount) = overallCount;
    node1dTo2d(overallCount,:) = [t frameCount];
    frameCount = frameCount + 1;
    overallCount = overallCount + 1;
  end
  present{t} = find(status(:,t) ~= absent);
  numPresent(t) = numel(present{t});
  assert(numPresent(t) == frameCount-1)
end
assert(sum(numPresent) == overallCount-1)

Ndet = overallCount-1;
trueBel = zeros(Nplayers, Ndet);
for d=1:Ndet
  delta = zeros(Nplayers,1);
  delta(truth(d))=1;
  trueBel(:,d) = delta;
end

 % find successor for each detection
 succ = cell(1,Nframes);
for t=1:Nframes-1
  pr = present{t};
  for d=1:numel(pr)
    myid = pr(d);
    j = find(present{t+1}==myid); % j is successor of det(d)
    if isempty(j)
      succ{t}(d) = NaN;
    else
      succ{t}(d) = j;
    end
  end
end

% make noisy successors
noisysucc = succ;
for t=1:Nframes-1
  if isempty(succ{t}), continue; end
  flip = rand(1,1)<noiseLevelLinkage;
  if flip
    followers = succ{t};
    perm = randperm(numel(followers));
    noisysucc{t} = succ{t}(perm);
  end
end

data = structure(frontalShot, appearanceVec, colorVec, ...
  present, succ, noisysucc, numPresent, ...
  node2dTo1d, node1dTo2d,  Nplayers, Nframes, isPresent, ...
  trueId, truth, trueBel);
end


function [obsModel, Nmix] = mkAppearanceModel(Nplayers, obsNoiseLevel, Nmix, nfeatures)
for p=1:Nplayers+1;
  K = Nmix(p);
  mu = randn(nfeatures, K);
  Sigma = repmat(obsNoiseLevel*eye(nfeatures),[1 1 K]);
  mixWeight = normalize(ones(1,K));
  obsModel{p} = mixModelCreate(condGaussCpdCreate(mu, Sigma),...
    'gauss', K, mixWeight);  
end
end


function cancolors = mkCanonicalColors(obsModel)
N = numel(obsModel);
[colors] = pmtkColors;
c = 1;
for p=1:N
  Nmix(p) = obsModel{p}.nmix;
  for m=1:Nmix(p)
    cancolors{p}{m} = colors{c};
    c = c+1;
  end
end
if 0
% let us hard-code the colors so they match
% the colors produced by the bar command
% for the valid players
% This only works if we have Nmix=1 for each model
cancolors{1}{1} = [0 0 1];
cancolors{2}{1} = [0 1 0];
cancolors{3}{1} = [1 0 0];
cancolors{4}{1} = [1/3 1/3 1/3];
end
end




function drawData(data, varargin)
[plotTitle, times] = process_options(varargin, ...
   'plotTitle', true, 'times', 1:min(30,data.Nframes));
Nplayers = data.Nplayers;
Nframes = numel(times);
[ynum, xnum] = nsubplots(Nframes);
figure;
for ti=1:Nframes
  t = times(ti);
  subplot(ynum, xnum, ti);
  i = 1; % indexes detections within a frame
  for p=1:Nplayers
    if ~data.isPresent(t,p), continue; end
    j = data.node2dTo1d(t,i);
    color = data.colorVec(:,j);
    plot(p, 0, 'o','markerfacecolor', color, 'markersize', 10);
    hold on
    i = i + 1;
  end
  set(gca,'xlim',[0 Nplayers+1]);
  set(gca,'ylim',[-10 10]);
  if plotTitle
    if data.numPresent(t) > 0
      firstDetection = data.node2dTo1d(t, 1);
      lastDetection = data.node2dTo1d(t, data.numPresent(t));
      title(sprintf('%d (%d:%d)', t, firstDetection, lastDetection));
    else
      title(sprintf('%d:', t))
    end
  end
  %axis off
  set(gca, 'xtick', [])
  set(gca, 'ytick', [])
end
end



function drawBel(bel, data, varargin)
[plotTitle, times] = process_options(varargin, ...
  'plotTitle', true, 'times', 1:min(30,data.Nframes));
% bel(:,j) is belief state for node j
Nframes = numel(times);
[ynum, xnum] = nsubplots(Nframes);
figure;
emptyBel = 0.01*ones(data.Nplayers,1);
for ti=1:Nframes
  t = times(ti);
  subplot(ynum, xnum, ti);
  belFrame = zeros(data.Nplayers, data.Nplayers);
  d = 1; % counts detections
  for p=1:data.Nplayers
    if ~data.isPresent(t,p)
      belFrame(:,p) = emptyBel;
    else
      j = data.node2dTo1d(t, d);
      belFrame(:,p) = bel(:,j);
      d = d+1;
    end
  end
  bar(belFrame')
  if plotTitle
    title(sprintf('t=%d',t))
  end
  set(gca, 'xtick', [])
  set(gca, 'ytick', [])
  set(gca, 'ylim', [0 1])
end
drawnow
end

function printBel(bel, data, varargin)
[times] = process_options(varargin, ...
   'times', 1:min(30,data.Nframes));
% bel(:,j) is belief state for node j
Nframes = numel(times);
for ti=1:Nframes
  t = times(ti);
  fprintf('\nframe %d: \n', t);
  for d=1:data.numPresent(t)
    j = data.node2dTo1d(t, d);
    str = sprintf('%4.2f,', bel(:,j));
    fprintf('det %d: truth = %d, bel = %s\n', ...
      d, data.trueId(t,d), str);
  end
end
end


function loss = KLbel(belTrue, belApprox)
% belTrue(:,j) = belief for j'th node
Nnodes = size(belTrue,2);
belTrue = normalize(belTrue + eps,1);
belApprox = normalize(belApprox + eps,1);
loss = 0;
for j=1:Nnodes
  loss = loss + sum(belTrue(:,j) .* (log(belTrue(:,j)) - log(belApprox(:,j))));
end
end

function [KLloss, errRate] = evalPerf(bel, data)
[junk, mapEst] = max(bel,[],1); %#ok  1-by-ndet
nerrs = sum(mapEst ~= data.truth);
errRate = nerrs/numel(mapEst);
KLloss = KLbel(data.trueBel, bel);
end
