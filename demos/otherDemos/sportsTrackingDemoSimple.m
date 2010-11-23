%% Generate synthetic labeled data
% of 'players' along with
% perfect tracking info and weak lables saying who is in view
% but without correspondence information.
% Appearance of players is colored rectangles.
% Motion is  random around fixed location, but we assume perfect tracking.

% PMTKinprogress

% This file is from pmtk3.googlecode.com


function sportsTrackingDemo()

setSeed(2);
Nplayers = 3;
Nframes = 30;

% Assign player locations 
% centers(:,i) is [x y] center of i'th ellipse
courtSize = 100;
playerSize = 10;
if 0
centers = zeros(2, Nplayers);
minS = courtSize/2 - 2*playerSize;
maxS = courtSize/2 + 2*playerSize;
centers(1,:) = round(unifrnd(minS, maxS, 1, Nplayers));
centers(2,:) = round(unifrnd(minS, maxS, 1, Nplayers));
end
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

unidentColor = [1/3 1/3 1/3]';
colorNoiseLevel = 0.3; % 0 to 0.5 (0 is easiest)

% Make an hmm which controls visibility of players
% states = identifiable (unique color - eg frontal view),
%  unidentifiable (ambiguous color),
%  absent (not in view)
id = 1; unid = 2; absent = 3;
T = zeros(3,3);
T(id,id) = 0.2;
T(id, unid) = 0.8;
T(unid, unid) = 0.7;
T(unid, id) = 0.2;
T(unid, absent) = 0.1;
T(absent, absent) = 0.2;
T(absent, unid) = 0.8;
assert(approxeq(T, mkStochastic(T)))
initStateDist = [1/3 1/3 1/3];
markovModelForVisStatus = markovCreate(initStateDist, T);

params = structure(centers, colors, unidentColor, ...
  colorNoiseLevel, playerSize, courtSize,  markovModelForVisStatus);


%% Visualize data

data = generateData(params, Nframes);
[codebook, data.Ovec, data.Ocell]  = vectorQuantize(data, params);
drawPlayers(data, params);
set(gcf, 'name', 'raw data + VQ')
printPmtkFigure('sportsRaw')

%celldisp(data.succ)
X = rowvec(data.Ovec); % 1*N, N=sum_t N(t),  X(j) in 1..K


%% Inference in an iid model

mrfNoEdges = mkGmNoEdges(data, codebook, Nplayers);
belNoEdges = tfMarg2Mat(mrfInferNodes(mrfNoEdges, 'localev', X)); 
belNoEdgesCell = timeSeriesToCell(belNoEdges, data.numPresent);
drawBel(belNoEdgesCell);
%suptitle('no edges')
set(gcf, 'name', 'no edges')
printPmtkFigure('sportsBelNoEdges')

if 0 %debugging - don't even need GM code if graph is disconnected
CPT = mkLocalCpt(codebook, Nplayers);
softev = CPT(:, X); % softev(i,j), player i, detection j
post = normalize(softev, 1);
postCell = timeSeriesToCell(post, data.numPresent);
drawBel(postCell)
assert(isequal(postCell, belCell))
end


%% Inference in a model with temporal connections

mrfTime = mkGmTemporalEdges(data, codebook, Nplayers);
belTime = tfMarg2Mat(mrfInferNodes(mrfTime, 'localev', X)); 
belTimeCell = timeSeriesToCell(belTime, data.numPresent);
drawBel(belTimeCell); 
%suptitle('temporal edges')
set(gcf, 'name', 'temporal edges')
printPmtkFigure('sportsBelTime')

% There is a bug in map estimation for disconnected grapshs
% so we use max marginals instead
%mapTime = mrfMap(mrfTime, 'localEv', X) % Viterbi
mapTime = maxidx(belTime, [], 1); % max marginals
mapTimeCell = timeSeriesToCell(rowvec(mapTime), data.numPresent);
drawPlayers(data, params, mapTimeCell);
set(gcf, 'name', 'temporal edges')
printPmtkFigure('sportsMapTime')
end

function model = mkGmNoEdges(data, codebook, Nplayers)
localCPT = mkLocalCpt(codebook, Nplayers);
localCPD = tabularCpdCreate(localCPT);
Nnodes = sum(data.numPresent);
G = zeros(Nnodes, Nnodes); % no edges!
nodePot = ones(Nplayers, 1); % not used
edgePot = []; % not used
model     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePot,...
    'localCPDs', localCPD);
end

function model = mkGmTemporalEdges(data, codebook, Nplayers)
localCPT = mkLocalCpt(codebook, Nplayers);
localCPD = tabularCpdCreate(localCPT);
Nnodes = sum(data.numPresent); % num detections
G = zeros(Nnodes, Nnodes); 
Nframes = numel(data.present);
for t=1:Nframes-1
  for i = 1:data.numPresent(t)  % i,j index detections not players
    j = data.succ{t}(i);
    if ~isnan(j)
      srcNode = data.node2dTo1d(t, i);
      destNode = data.node2dTo1d(t+1, j);
      G(srcNode, destNode) = 1;
    end
  end
end
nodePot = ones(Nplayers, 1); % not used
edgePot = eye(Nplayers, Nplayers); % hard constraint
model     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePot,...
    'localCPDs', localCPD);
end





function data = generateData(params, Nframes)
% Output:
% status(i,t) = unident, ident or absent
% locns{t}(:,i) = [x y] of i'th detection in frame t
% colors{t}(:,i) = [r g b]
% present{t} = [list of player ids present - in order!]
% succ{t}(i) = successor of detection i, or NaN if none
% numPresent(t) = numel(present{t})

id = 1; unid = 2; absent = 3;
Nplayers = size(params.colors, 2);

% visibility status is just used internally to decide
% color of player
status = markovSample(params.markovModelForVisStatus, Nframes, Nplayers);
if 0
% Simple test example: each row is a frame
status = [unid,  id,  absent;
          id, id, absent;
          absent, unid, id]';
end

Nframes = size(status, 2);
overallCount = 1;
for t=1:Nframes
  frameCount = 1; % counts number of detections per frame
  statusFrame = status(:,t);
  for i=1:Nplayers
    % frameCount is the 'local' number for player i
    if statusFrame(i)==absent, continue; end % skip absent players
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
  node2dTo1d, node1dTo2d, status);
end

function CPD = mkLocalCpt(codebook, Nplayers)
% CPD(i,k) = prob player i can generate codeword k
K = size(codebook,2);
% we cheat and assume that player i can generate
% codebook i's entry with high prob.
% It can also generate the unidentified color (codebook(end))
% For robustness, we let it generate all other entries too
%CPD = zeros(Nplayers, K);
epsilon = 0.1;
%CPD = setdiag(CPD, 1-epsilon);
%CPD(:, end) = epsilon; % last column = unid color
CPD = epsilon*ones(Nplayers, K);
CPD = mkStochastic(setdiag(CPD, 1-epsilon));
assert(approxeq(CPD, mkStochastic(CPD)))
end


function [codebook, symbols, Ocell] = vectorQuantize(data, params)
% codebook(:,k) is k'th color cluster
% O{t} is vector of discrete observation id's
colors = cell2mat(data.colors);
%K = 5; 
%[codebook, symbols] = kmeansFit(colors', K);
% set the codebook columns to the true colors  - this is cheating
codebook = [params.colors, params.unidentColor(:) ];
symbols = kmeansEncode(colors', codebook);
Ocell = timeSeriesToCell(rowvec(symbols), data.numPresent);
end

function c = timeSeriesToCell(ts, numPresent)
% ts(:,j) = vector for j'th detection
% c{t}(:,i) = i'th detection in frame t, i=1:numPresent(t)
Nframes = numel(numPresent);
j = 1;
for t=1:Nframes
  for cnt=1:numPresent(t)
    c{t}(:,cnt) = ts(:,j);
    j = j + 1;
  end
end
end


function drawPlayers(data, params, mapEstCell)
if nargin < 3, mapEstCell = []; end
id = 1; unid = 2; absent = 3;
Nplayers = size(params.colors, 2);
Nframes = numel(data.locns);
[ynum, xnum] = nsubplots(Nframes);
figure;
for t=1:Nframes
  subplot(ynum, xnum, t);
  statusFrame = data.status(:,t);
  i = 1; % indexes detections within a frame
  for p=1:Nplayers
    if statusFrame(p) == absent, continue; end % skip absent players
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
    if statusFrame(p) == id
      % if unique view, mark with an x
      plot(mu(1), mu(2), 'kx', 'markersize', 12, 'linewidth', 3);
    end
    i = i + 1;
  end
  set(gca,'xlim',[-params.courtSize, params.courtSize]);
  set(gca,'ylim',[-params.courtSize, params.courtSize]);
  %title(sprintf('%d: %s', t, sprintf('%d,', data.present{t})))
  title(sprintf('%d: %s', t, sprintf('%d,', data.Ocell{t})))
  %axis off
  set(gca, 'xtick', [])
  set(gca, 'ytick', [])
end
end


function drawBel(belCell)
Nframes = numel(belCell);
[ynum, xnum] = nsubplots(Nframes);
figure;
for t=1:Nframes
  subplot(ynum, xnum, t);
  bar(belCell{t}');
  title(sprintf('%d', t))
end
end

