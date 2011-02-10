% PMTKinprogress

% We incorporate label information as well
% as observed colors

% This file is from pmtk3.googlecode.com


function sportsTrackingDemoLabels()

setSeed(0);
folder = 'C:\kmurphy\People\JoAnneTing\sports';

%% Set parameters
Nplayers = 3;

% Assign player locations 
% centers(:,i) is [x y] center of i'th ellipse
courtSize = 100;
playerSize = 10;
centers = [-80 0; 0 0; 80 0]';

% Assign appearnace RGB
% If player is absent nothing is drawn
% If player is unidentifiabile, we use the same
% color regardless of player id
colors = zeros(3, Nplayers);
colors(:,1) = [0 0 1]';
colors(:,2) = [0 1 0]';
colors(:,3) = [1 0 0]';
% we use blue for player 1 so color matches bar's colors

% If a player is in the unidentified state,
% we sample its color from a distribution
% centered at this value
unidentColor = [1/3 1/3 1/3]';

% When we generate a color, we add noise
% to it with this noise level
colorNoiseLevel = 0; % 0 to 0.5 (0 is easiest)

params = structure(centers, colors, unidentColor, ...
  colorNoiseLevel, playerSize, courtSize);

%% Make data

dataTrain = generateData(params, 100);
dataTest = generateData(params, 30);

% vector quantize
% codebook(:,k) is k'th color cluster
% set the codebook columns to the true colors 
% used to generate the data - this is cheating!
codebook = [params.colors, params.unidentColor(:) ];
Ncodewords = size(codebook,2);
dataTrain.Ovec = kmeansEncode(cell2mat(dataTrain.colors)', codebook);
dataTest.Ovec = kmeansEncode(cell2mat(dataTest.colors)', codebook);
% data.Ovec(j) = k means j'th detection looks like codeword k

%% Visualize data
drawPlayers(dataTrain, params);
set(gcf, 'name', 'train data + VQ')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainData.png'))

drawPlayers(dataTest, params);
set(gcf, 'name', 'test data + VQ')
print(gcf, '-dpng', fullfile(folder, 'sportsTestData.png'))



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


%{
% Cheat by using the oracular observation CPD
% but no label info. We use temporal and mutex arcs.
% This is exactly the same as sportsTrackingDemoMutex.
oracleCPD = tabularCpdCreate(mkObsCpt(codebook, Nplayers));
bel= inferBel(dataTrain, 'none', oracleCPD);
drawBel(bel, dataTrain); 
set(gcf, 'name', 'oracle CPD, no labels,  training set')


% Now use uniform CPD but unique labels
% Posterior marginals should be exact.
% This is what will be used to drive learning.
uniformCPD = tabularCpdCreate(mkStochastic(ones(Nplayers, Ncodewords)));
bel = inferBel(dataTrain, 'unique', uniformCPD);
drawBel(bel, dataTrain); 
set(gcf, 'name', 'uniform CPD,  unique labels,  training set')

%}


% train up a model from unique labels
% We don't need GM structure in this case
[trainedCPD] = learnCPD(dataTrain, 'unique', Ncodewords, ...
  {'useMutex', false, 'useTemporal', false});
bel = inferBel(dataTrain, 'none', trainedCPD);
drawBel(bel, dataTrain); 
set(gcf, 'name', 'CPD trained on unique labels, applied to unlabeled training set')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainedOnUniqueNoGM.png'))


% train up a model from soft labels without using GM strucutre
% This should fail, since the local beliefs will be too uninformed.
[trainedCPD] = learnCPD(dataTrain, 'soft', Ncodewords, ...
  {'useMutex', false, 'useTemporal', false});
bel = inferBel(dataTrain, 'none', trainedCPD);
drawBel(bel, dataTrain);
set(gcf, 'name', 'CPD trained on soft labels without GM, applied to unlabeled training set')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainedOnSoftNoGM.png'))



% train up a model from soft labels using GM
[trainedCPD] = learnCPD(dataTrain, 'soft', Ncodewords);
bel = inferBel(dataTrain, 'none', trainedCPD);
drawBel(bel, dataTrain);
set(gcf, 'name', 'CPD trained on soft labels, applied to unlabeled training set')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainedOnSoft.png'))

% now apply to test set
bel = inferBel(dataTest, 'none', trainedCPD);
drawBel(bel, dataTest);
set(gcf, 'name', 'CPD trained on soft labels, applied to unlabeled test set')
print(gcf, '-dpng', fullfile(folder, 'sportsTrainedOnSoftTestSet.png'))


%{
% sanity check - train up a model from no labels
% This should give uniform beliefs
[trainedCPD] = learnCPD(dataTrain, 'none', Ncodewords);
bel = inferBel(dataTrain, 'none', trainedCPD);
drawBel(bel, dataTrain);
set(gcf, 'name', 'CPD trained on no labels, applied to unlabeled training set')
%}

keyboard


end

function [trainedCPD, mrf] = learnCPD(data, labelType, Ncodewords, mrfArgs)
if nargin < 4, mrfArgs = {}; end
uniformCPD = tabularCpdCreate(mkStochastic(ones(data.Nplayers, Ncodewords)));
nodePots = mkNodePotsFromLabels(data, labelType);
mrf = mkMrf(data, nodePots, 'localCPD', uniformCPD, mrfArgs{:});
% We hold the label info fixed (burned into the nodePots)
% while we re-evaluate the localEv as the localCPD params change.
mrf = mrfTrainEm(mrf, [], 'localev', rowvec(data.Ovec), 'verbose', true);
trainedCPD = mrf.localCPDs{1};
end


function bel = inferBel(data, labelType, localCPD)
nodePots = mkNodePotsFromLabels(data, labelType);
mrf = mkMrf(data, nodePots, 'localCPD', localCPD);
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

[useTemporal, useMutex, localCPD] = process_options(varargin, ...
  'useTemporal', true, 'useMutex', true, 'localCPD', []);

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
    'edgePotPointers', edgePotPointers, 'localCPDs', localCPD);
end



function data = generateData(params, Nframes)
% Output: data is a struct with these fields
% status(i,t) = unident, ident or absent
% locns{t}(:,i) = [x y] of i'th detection in frame t
% colors{t}(:,i) = [r g b]
% present{t} = [list of player ids present - in order!]
% succ{t}(i) = successor of detection i, or NaN if none
% numPresent(t) = numel(present{t})

Nplayers = size(params.colors, 2);
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

Nframes = size(status, 2);
overallCount = 1;
isPresent = true(Nframes, Nplayers);
for t=1:Nframes
  frameCount = 1; % counts number of detections per frame
  statusFrame = status(:,t);
  for i=1:Nplayers
    % frameCount is the 'local' number for player i
    % skip absent players
    if statusFrame(i)==absent
      isPresent(t,i) = false;
      continue;
    end 
    locns{t}(:,frameCount) = params.centers(:,i);
    if statusFrame(i)==unid
     mu = params.unidentColor;
    else
      mu = params.colors(:,i);
    end
    % perturb the color in each r,g,b dimension
    for d=1:3
      mu(d) = mu(d) + params.colorNoiseLevel*unifrnd(-1,1,1);
      mu(d) = min(mu(d), 1);
      mu(d) = max(mu(d), 0);
    end
    colors{t}(:,frameCount) = mu;
    
    node2dTo1d(t,frameCount) = overallCount;
    node1dTo2d(overallCount,:) = [t frameCount];
    frameCount = frameCount + 1;
    overallCount = overallCount + 1;
  end
  present{t} = find(statusFrame ~= absent);
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

data = structure(locns, colors, present, succ, numPresent, ...
  node2dTo1d, node1dTo2d,  Nplayers, Nframes, isPresent);
end

function CPT = mkObsCpt(codebook, Nplayers)
% CPT(i,k) = prob player i can generate observed codeword k
K = size(codebook,2);
% we cheat and assume that player i can generate
% codebook i's entry with high prob.
% It can also generate the unidentified color (codebook(end))
% For robustness, we let it generate all other entries too
%CPD = zeros(Nplayers, K);
epsilon = 0.1;
CPT = epsilon*ones(Nplayers, K);
CPT = mkStochastic(setdiag(CPT, 1-epsilon));
assert(approxeq(CPT, mkStochastic(CPT)))
end



function drawPlayers(data, params, mapEstCell)
if nargin < 3, mapEstCell = []; end
id = 1; unid = 2; absent = 3;
Nplayers = size(params.colors, 2);
Nframes = min(30,numel(data.locns));
[ynum, xnum] = nsubplots(Nframes);
figure;
for t=1:Nframes
  subplot(ynum, xnum, t);
  i = 1; % indexes detections within a frame
  for p=1:Nplayers
    % skip absent players 
    if ~data.isPresent(t,p), continue; end
    mu = data.locns{t}(:,i);
    if ~isempty(mapEstCell)
      % use color associated with estimated person
      color = params.colors(:, mapEstCell{t}(i));
    else
      % use observed color
      color = data.colors{t}(:,i);
    end
    plot(mu(1), mu(2), 'o','markerfacecolor', color, ...
      'markersize', params.playerSize);
    hold on
    i = i + 1;
  end
  set(gca,'xlim',[-params.courtSize, params.courtSize]);
  set(gca,'ylim',[-params.courtSize, params.courtSize]);
  if data.numPresent(t) > 0
     firstDetection = data.node2dTo1d(t, 1);
     lastDetection = data.node2dTo1d(t, data.numPresent(t));
     title(sprintf('%d (%d:%d)\n %s', t, firstDetection, lastDetection, ...
        sprintf('%d,', data.Ovec(firstDetection:lastDetection))))
  else
     title(sprintf('%d:', t))
  end
  
  %axis off
  set(gca, 'xtick', [])
  set(gca, 'ytick', [])
end
end


function drawBel(bel, data)
Nframes = min(30, size(bel,2));
[ynum, xnum] = nsubplots(Nframes);
figure;
emptyBel = 0.01*ones(data.Nplayers,1);
j = 1;
for t=1:Nframes
  subplot(ynum, xnum, t);
  belFrame = zeros(data.Nplayers, data.Nplayers);
  for i=1:data.Nplayers
    if ~data.isPresent(t,i)
      belFrame(:,i) = emptyBel;
    else
      belFrame(:,i) = bel(:,j);
      j = j+1;
    end
  end
  bar(belFrame')
  title(sprintf('t=%d',t))
  set(gca, 'xtick', [])
  set(gca, 'ytick', [])
  set(gca, 'ylim', [0 1])
end
end


