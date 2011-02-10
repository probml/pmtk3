% like sportsTrackingDemoNoisy, but we 
% use approximate inference.
% We stick to Nplayers=4 so we can compare
% to exact inference.

% This file is from pmtk3.googlecode.com

% PMTKinprogress
function sportsTrackingDemoApprox()

setSeed(0);
folder = 'C:\kmurphy\People\JoAnneTing\sports';


%% Make data
Nplayers = 4;
[obsModel] = mkAppearanceModel(Nplayers);
cancolors = mkCanonicalColors(obsModel);
 
dataTrain = generateData(100, Nplayers, obsModel, cancolors);
%dataTest = generateData(30, Nplayers, obsModel, cancolors);

%% vector quantize
% codebook(:,k) is k'th color cluster

K = 10;
X = dataTrain.appearanceVec';
codebook = kmeansFit(X, K);
%[idx, C] = kmeans(X, K, 'replicates', 5, 'emptyAction', 'drop');
%codebook = C' 


%{
% To help ensure we allocate a codeword to every
% players unique appearance (which are rare),
% we partition the data into frontal shots
% and others. We learn two separate codebooks
% and then merge them.
% If we don't do this, we may fail to allocate
% a cluster center to the rare but important frontal shots.
X = dataTrain.appearanceVec';
Xfrontal = X(dataTrain.frontalShot,:);
codebookFrontal = kmeansFit(Xfrontal, Nplayers)
Xside = X(~dataTrain.frontalShot,:);
codebookSide = kmeansFit(Xside, 2)
codebook = [codebookFrontal codebookSide];
%figure; imagesc(codebook); title('codebook, columns = codewords')
%}

Ncodewords = size(codebook,2);
dataTrain.Ovec = kmeansEncode(dataTrain.appearanceVec', codebook);
%dataTest.Ovec = kmeansEncode(dataTest.appearanceVec', codebook);
% data.Ovec(j) = k means j'th detection looks like codeword k

%% Visualize data
%{
drawData(dataTrain,  'times', 1:100, 'plotTitle', false);
set(gcf, 'name', 'train data')
%}
drawData(dataTrain);
set(gcf, 'name', 'train data + VQ')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainData.png'))

%{
drawData(dataTrain, 'times', 31:60);
set(gcf, 'name', 'train data + VQ')

drawData(dataTest);
set(gcf, 'name', 'test data + VQ')
print(gcf, '-dpng', fullfile(folder, 'sportsTestData.png'))
%}


%% Main body


% incorporate label info  during training.
% If labelType = 'unique'
%  then softEvLabels(:,j) = deltaFn on true id for j
%  which amounts to clamping the hidden nodes to their true label
% If labelType = 'soft',
%   softEvLabels(:,j) = uniform over all players in j's frame.
%   If all players are present, this gives us no info
% If labelType = 'none',
%   softEvLabels(:,j) = uniform over all players 
%   which amounts to having no labels

figure;bar(ones(2,Nplayers));title('color key')
print(gcf, '-dpng', fullfile(folder, 'sportsBarKey.png'))


% use unique labels so posterior is delta function on truth
uniformCPD = tabularCpdCreate(mkStochastic(ones(Nplayers, Ncodewords)));
belTrue = inferBel(dataTrain, 'unique', uniformCPD, 'infEngine', 'jtree');
drawBel(belTrue, dataTrain);
ttl = 'hard labels, exact inf';
set(gcf, 'name', ttl)

belApprox = inferBel(dataTrain, 'unique', uniformCPD, 'infEngine', 'TRWBP'); 
drawBel(belTrue, dataTrain);
ttl = sprintf('hard labels, approx inf, KL %8.5f', KLbel(belTrue, belApprox));
set(gcf, 'name', ttl)

%{
% train up a model from unique labels (fully labeled training set)
[trainedCPD] = learnCPD(dataTrain, 'unique', Ncodewords);
bel = inferBel(dataTrain, 'none', trainedCPD);
drawBel(bel, dataTrain); 
set(gcf, 'name', 'CPD trained on unique labels, applied to unlabeled training set')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainedOnUniqueNoGM.png'))
%}

% train up a model from soft labels using exact inference
tic
[trainedCPD] = learnCPD(dataTrain, 'soft', Ncodewords, 'infEngine', 'jtree');
bel = inferBel(dataTrain, 'none', trainedCPD,  'infEngine', 'jtree');
toc
drawBel(bel, dataTrain);
ttl = sprintf('trained on soft labels, exact inf, KL %8.5f', KLbel(belTrue, bel));
set(gcf, 'name', ttl)
print(gcf, '-dpng', fullfile(folder, 'sportsTrainedExact.png'))

% train up a model from soft labels using approximate inference
tic
[trainedCPD] = learnCPD(dataTrain, 'soft', Ncodewords, 'infEngine', 'TRWBP');
bel = inferBel(dataTrain, 'none', trainedCPD, 'infEngine', 'TRWBP');
toc
drawBel(bel, dataTrain);
ttl = sprintf('trained on soft labels, approx inf, KL %8.5f', KLbel(belTrue, bel));
set(gcf, 'name', ttl)
print(gcf, '-dpng', fullfile(folder, 'sportsTrainedApprox.png'))


keyboard


end

function [trainedCPD, mrf] = learnCPD(data, labelType, Ncodewords, varargin)
[mrfArgs, infEngine] = process_options(varargin, ...
  'mrfArgs', {}, 'infEngine' , 'jtree');
uniformCPD = tabularCpdCreate(mkStochastic(ones(data.Nplayers, Ncodewords)));
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
    infEngArgs = {'TRWBP', '[updates=SEQFIX,tol=1e-9,maxiter=10000,logdomain=0,nrtrees=0]'};
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

function obsModel = mkAppearanceModel(Nplayers)
nfeatures = 5;
Nmix = [1*ones(1,Nplayers) 2];
for p=1:Nplayers+1;
  K = Nmix(p);
  mu = rand(nfeatures, K);
  Sigma = repmat(0.01*eye(nfeatures),[1 1 K]);
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
  node2dTo1d, node1dTo2d,  Nplayers, Nframes, isPresent);
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
