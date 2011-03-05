% PMTKinprogress

% like sportsTrackingDemoApprox,
% but easier to compare exact and approx

% This file is from pmtk3.googlecode.com


function sportsTrackingDemoLoopy()


folder = 'C:\kmurphy\People\JoAnneTing\sports';

Nplayers = 4;
for trial=1:2
  if trial==1
    infEngine = 'jtree';
  else
    infEngine = 'TRWBP';
  end
  
setSeed(0);
[obsModel, Nmix] = mkAppearanceModel(Nplayers);
cancolors = mkCanonicalColors(obsModel);
 
dataTrain = generateData(100, Nplayers, obsModel, cancolors);
%dataTest = generateData(30, Nplayers, obsModel, cancolors);

%% vector quantize
% codebook(:,k) is k'th color cluster

% We need at least one codeword per appearnace prototype.
% We allow a little extra to handle noise.
% In real data, we don't know what K should be...
% Hopefully it is relatively harmless to make it overly large
% (perhaps use an entropic prior on the emission matrix?)
K = ceil(1.1*sum(Nmix)); 
X = dataTrain.appearanceVec';
codebook = kmeansFit(X, K);
%[idx, C] = kmeans(X, K, 'replicates', 5, 'emptyAction', 'drop');
%codebook = C' 


Ncodewords = size(codebook,2);
dataTrain.Ovec = kmeansEncode(dataTrain.appearanceVec', codebook);

%% Visualize data

drawData(dataTrain);
set(gcf, 'name', 'train data + VQ')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainData.png'))



%% Main body


% train up a model from soft labels
tic
[trainedCPD] = learnCPD(dataTrain, 'soft', Ncodewords, 'infEngine', infEngine);
trainTime = toc
trainedCPD.T;

% apply model to data with no labels
tic
bel = inferBel(dataTrain, 'none', trainedCPD, 'infEngine', infEngine);
testTime = toc
%printBel(bel, dataTrain)


[junk, mapEst] = max(bel,[],1); % 1-by-ndet
figure; hold on
ndx = 1:50;
plot(dataTrain.truth(ndx), 'o');
plot(mapEst(ndx), 'rx');
legend('truth', 'map est')
nerr = sum(mapEst ~= dataTrain.truth);
ttl = sprintf('nerr=%d, inf=%s, trainTime=%5.3f, testTime=%5.3f,  Ncodewords=%d', ...
  nerr, infEngine, trainTime, testTime, Ncodewords)
title(ttl);
print(gcf, '-dpng', fullfile(folder, sprintf('results-%s.png', infEngine)))


end

keyboard

end

function [trainedCPD, mrf] = learnCPD(data, labelType, Ncodewords, varargin)
[mrfArgs, infEngine] = process_options(varargin, ...
  'mrfArgs', {}, 'infEngine' , 'jtree');
T = mkStochastic(ones(data.Nplayers, Ncodewords));
uniformCPD = tabularCpdCreate(T, 'prior', 1);
nodePots = mkNodePotsFromLabels(data, labelType);
mrf = mkMrf(data, nodePots, 'localCPD', uniformCPD, 'infEngine', ...
  infEngine, mrfArgs{:});
% We hold the label info fixed (burned into the nodePots)
% while we re-evaluate the localEv as the localCPD params change.
mrf = mrfTrainEm(mrf, [], 'localev', rowvec(data.Ovec), 'verbose', true);
trainedCPD = mrf.localCPDs{1};
end


function bel = inferBel(data, labelType, localCPD, varargin)
[infEngine] = process_options(varargin, ...
  'infEngine' , 'jtree');
nodePots = mkNodePotsFromLabels(data, labelType);
mrf = mkMrf(data, nodePots, 'localCPD', localCPD, 'infEngine', infEngine);
bel = tfMarg2Mat(mrfInferNodes(mrf, 'localev', rowvec(data.Ovec)));
%belCell = timeSeriesToCell(bel, data.numPresent);
end
 
 
function nodePots = mkNodePotsFromLabels(data, labelType)
if strcmpi(labelType, 'none')
  nodePots = ones(data.Nplayers, 1);
  return;
end
softEvLabels = mkSoftEvidenceFromLabels(data, labelType);
Nnodes = size(softEvLabels,2);
nodePots = cell(1,Nnodes);
%model.obsCpt = mkObsCpt(codebook, Nplayers);
%softEvObs = model.obsCpt(:, data.Ovec); % softEv(:,j) = likelihood for j'th node
for j=1:Nnodes
   dom = j;
   %nodePots{j}  = tabularFactorCreate(softEvObs(:,j) .* softEvLabels(:,j), dom);
   nodePots{j}  = tabularFactorCreate(softEvLabels(:,j), dom);
   %nodePots{j}  = tabularFactorCreate(softEvObs(:,j), dom);
end
end

function softEvLabels = mkSoftEvidenceFromLabels(data, labelType)
% softEvLabels(k,j) = likelihood player k is  present at node j
% Does not need to be normalized
Nframes = numel(data.present);
Nnodes = sum(data.numPresent);
Nplayers = data.Nplayers;
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

function mrf = mkMrf(data, nodePots, varargin)
[useTemporal, useMutex, localCPD, infEngine] = process_options(varargin, ...
  'useTemporal', true, 'useMutex', true, 'localCPD', [], 'infEngine', 'jtree');

switch lower(infEngine)
  case 'trwbp'
    infEngine = 'libdai';
    infEngArgs = {'TRWBP', '[updates=SEQFIX,tol=1e-3,maxiter=1000,logdomain=0,nrtrees=0]'};
  case 'jtree'
    infEngine = 'jtree';
    infEngArgs = {};
end


Nplayers = data.Nplayers;
Nframes = numel(data.present);
Nnodes = sum(data.numPresent); % num detections
G = zeros(Nnodes, Nnodes); 
if useTemporal
  for t=1:Nframes-1
    for i = 1:data.numPresent(t)  % i,j index detections not players
      j = data.succ{t}(i); % successor
      if ~isnan(j)
        srcNode = data.node2dTo1d(t, i);
        destNode = data.node2dTo1d(t+1, j);
        G(srcNode, destNode) = 1;
      end
    end
  end
end
if useMutex
   for t=1:Nframes-1
    for i = 1:data.numPresent(t) 
      for j=i+1:data.numPresent(t) 
        srcNode = data.node2dTo1d(t, i);
        destNode = data.node2dTo1d(t, j);
        G(srcNode, destNode) = 1;
      end
    end
   end
end
G = mkSymmetric(G);

% hard constraint that identity must be constant over time
edgePotTemp = eye(Nplayers, Nplayers); 

% hard constraint that 2 nodes cannot share same identity
edgePotMutex = ones(Nplayers, Nplayers);
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

   
    
mrf     = mrfCreate(G, 'nodePots', nodePots, 'edgePots', edgePots,...
    'edgePotPointers', edgePotPointers, 'localCPDs', localCPD, ...
    'infEngine', infEngine, 'infEngArgs', infEngArgs);
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

T(absent, absent) = 0.2;
T(absent, unid) = 0.8;
assert(approxeq(T, mkStochastic(T)))
initStateDist = [1/3 1/3 1/3];
markovModelForVisStatus = markovCreate(initStateDist, T);
% visibility status is just used internally to decide
% color of player

% we sample the status of each player independently
status = markovSample(markovModelForVisStatus, Nframes, Nplayers);
end

function [obsModel, Nmix] = mkAppearanceModel(Nplayers)
nfeatures = 5;
Nmix = [2*ones(1,Nplayers) 5];
noiseLevel = 0.1;
for p=1:Nplayers+1;
  K = Nmix(p);
  mu = rand(nfeatures, K);
  Sigma = repmat(noiseLevel*eye(nfeatures),[1 1 K]);
  mixWeight = normalize(ones(1,K));
  obsModel{p} = mixModelCreate(condGaussCpdCreate(mu, Sigma),...
    'gauss', K, mixWeight);  
end
end


function data = generateData(Nframes, Nplayers, obsModel, cancolor)
% Output: data is a struct with these fields
% appearanceVec(:,d) = feature vector for d'th detection
% colorVec(:,d) = [r g b] for visualization only
% frontalShot(d) = 1 if this is a frontal (unique) view
% present{t} = [list of player ids present - in order of detection]
% succ{t}(i) = successor of detection i, or NaN if none
% numPresent(t) = numel(present{t})
% isPresent(t,p) = 1 if player p is present in frame t
% 

status = mkVisibilityStatus(Nplayers, Nframes);
id = 1; unid = 2; absent = 3;
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

 % find successor for each detection
for t=1:Nframes-1
  pr = present{t};
  for i=1:numel(pr)
    myid = pr(i);
    j = find(present{t+1}==myid); % detection j links to i
    if isempty(j)
      succ{t}(i) = NaN;
    else
      succ{t}(i) = j;
    end
  end
end

data = structure(frontalShot, appearanceVec, colorVec, ...
  present, succ, numPresent, ...
  node2dTo1d, node1dTo2d,  Nplayers, Nframes, isPresent, trueId, truth);
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
%{
% let us hard-code the colors so they match
% the colors produced by the bar command
% for the valid players
% This only works if we have Nmix=1 for each model
cancolors{1}{1} = [0 0 1];
cancolors{2}{1} = [0 1 0];
cancolors{3}{1} = [1 0 0];
cancolors{4}{1} = [1/3 1/3 1/3];
%}
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
      title(sprintf('%d (%d:%d)\n %s', t, firstDetection, lastDetection, ...
        sprintf('%d,', data.Ovec(firstDetection:lastDetection))))
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
