function [adj,hashTable,scoreTrace,evalTrace,adjTrace] = DAGlearn2_DAGsearch(...
  X,scoreType,SC,adj,A,maxEvals,hashTable, verbose, maxIter, maxFanIn)
% [adj,hashTable,scoreTrace,evalTrace,adjTrace] = DAGlearn2_DAGsearch(X,scoreType,SC,adj,A,maxEvals,hashTable, vberose)

if nargin < 8, verbose = false; end

ADDITION = 1;
DELETION = 2;
REVERSAL = 3;

DEBUG1 = 0; % Test whether adj remains acyclic
DEBUG2 = 0; % Test whether cached scores are correct

[nSamples,nNodes] = size(X);

if nargin < 3 || isempty(SC)
    SC = ones(nNodes);
end
SC = setdiag(double(SC~=0),0);
[edgeEnd1 edgeEnd2] = find(SC);

if nargin < 4 || isempty(adj)
    adj = zeros(nNodes);
end
adj = double(adj~=0);

if nargin < 5
    A = [];
end

if nargin < 6
    maxEvals = inf;
end

if nargin < 7
    hashTable = java.util.Hashtable;
end

% Compute score of initial graph
evals = 0;
if verbose >= 1, fprintf('Evaluating initial graph\n'); end
for c = 1:nNodes
    [score(c),miss] = computeScore(X,c,find(adj(:,c)),scoreType,A,hashTable);
    evals = evals + miss;
end

if nargout > 2
    evalTrace = evals;
    scoreTrace = sum(score);
    if nargout > 4
        adjTrace = adj;
    end
end

% Build Ancestor and Reversal Matrices
anc = ancMatrixBuild(adj);
rev = revMatrixBuild(adj,anc);

% KPM 19 march 2010: check for cyclcing
prevrev = []; % previous edge reversal
if verbose >= 1, fprintf('Evaluating all legal moves\n'); end
iter = 1;
while iter<maxIter
  iter = iter+1;
    minScore = 0;
    moveType = 0;
    prevMoveType = -1;
    for e = 1:length(edgeEnd1)
        p = edgeEnd1(e);
        c = edgeEnd2(e);
        if adj(p,c) == 1
            % Evaluate Deletion
            [score_del,miss] = computeScore(X,c,setdiff(find(adj(:,c)),p),scoreType,A,hashTable);
            evals = evals + miss;
            if score_del - score(c) < minScore
                minScore = score_del - score(c);
                newScore = score_del;
                moveType = DELETION;
                move = [p c];
            end
            
            if rev(p,c) == 0 && SC(c,p) == 1
               % KPM 19 march 2010
               % Check that this reversal is not on the list
               % of recently tried reversals (to prevent cycling)
               valid = true;
               for t=size(prevrev, 1):-1:1
                 if isequal(prevrev(t,1:2), [p c])
                   fprintf('tried reversing %d->%d in step %d\n', p, c, prevrev(t,3));
                   valid = false;
                   break;
                 end
               end
               if valid
                 % Evaluate legal reversal
                 [score_rev,miss] = computeScore(X,p,[c;find(adj(:,p))],scoreType,A,hashTable);
                 evals = evals + miss;
                 if score_del - score(c) + score_rev - score(p) < minScore
                   minScore = score_del - score(c) + score_rev - score(p);
                   newScore = [score_rev score_del];
                   moveType = REVERSAL;
                   move = [p c];
                   prevrev(end+1,:) = [p c evals];
                 end
               end
            end
        elseif (anc(c,p) == 0) && sum(find(adj(:,c)) < maxFanIn)
            % Evaluate legal addition
            [score_add,miss] = computeScore(X,c,[p;find(adj(:,c))],scoreType,A,hashTable);
            evals = evals + miss;
            if score_add - score(c) < minScore
                minScore = score_add - score(c);
                newScore = [score_add];
                moveType = ADDITION;
                move = [p c];
            end
        end
        prevMoveType = moveType;
    end
    
    
    if nargout > 2
        evalTrace(end+1,1) = evals;
    end
    
    if verbose >= 2, fprintf('Evals = %2.f, Score = %.2f, ',evals,sum(score)); end
    
    if moveType == 0
        if verbose >= 1, fprintf('Local Minimum Found\n'); end
        break
    end
    
    if evals > maxEvals;
        if verbose >= 1, fprintf('Maximum number of evals exceeded\n'); end
        break;
    end
    
    % Update score, adjacency matrix, ancestor matrix, reversal matrix
    p = move(1);
    c = move(2);
    switch moveType
        case ADDITION
            if verbose >= 2, fprintf('Adding Edge from %d to %d\n',p,c); end
            score(c) = newScore;
            adj(p,c) = 1;
            anc = ancMatrixAdd(anc,p,c);
            rev = revMatrixAdd(rev,adj,anc,p,c);
        case DELETION
            if verbose >= 2, fprintf('Deleting Edge from %d to %d\n',p,c); end
            score(c) = newScore;
            adj(p,c) = 0;
            anc = ancMatrixDelete(anc,p,c,adj);
            rev = revMatrixBuild(adj,anc);
        case REVERSAL
            if verbose >= 2, fprintf('Reversing Edge from %d to %d\n',p,c); end
            score(p) = newScore(1);
            score(c) = newScore(2);
            adj(p,c) = 0;
            anc = ancMatrixDelete(anc,p,c,adj);
            adj(c,p) = 1;
            anc = ancMatrixAdd(anc,c,p);
            rev = revMatrixBuild(adj,anc);
    end
    
    if nargout > 2
        scoreTrace(end+1,1) = sum(score);
        if nargout > 4
            adjTrace(:,:,end+1) = adj;
        end
    end
    
end

if nargout > 2
    scoreTrace(end+1,1) = nan;
    if nargout > 4
        adjTrace(:,:,end+1) = adj;
    end
end

end

function [score,miss] = computeScore(X,child,parents,scoreType,A,hashTable)

key = sprintf('%d ',[child;parents]);
val = hashTable.get(key);
if ~isempty(val)
    %fprintf('Hit!\n');
    score = val;
    miss = 0;
    return
end
%fprintf('Miss!\n');
miss = 1;

nSamples = size(X,1);
if isempty(A)
    intInd = [];
else
    intInd = A(:,child)~=0;
end

% Compute Score
options.Display = 0;
nZ = length(parents);
w = zeros(nZ,1);
if scoreType == 0
    if isempty(intInd)
        funObj = @(w)LogisticLoss(w,X(:,parents),X(:,child));
    else
        funObj = @(w)LogisticLoss(w,X(~intInd,parents),X(~intInd,child));
    end
    [w,f] = minFunc(funObj,w,options);
    score = 2*f + nZ*log(nSamples);
else
    trainNdx = [1:nSamples]' <= ceil(nSamples/2);
    if isempty(intInd)
        funObj = @(w)LogisticLoss(w,X(trainNdx,parents),X(trainNdx,child));
    else
        funObj = @(w)LogisticLoss(w,X(trainNdx & ~intInd,parents),X(trainNdx & ~intInd,child));
    end
    w = minFunc(funObj,w,options);
    if isempty(intInd)
        score = LogisticLoss(w,X(~trainNdx,parents),X(~trainNdx,child));
    else
        score = LogisticLoss(w,X(~trainNdx & ~intInd,parents),X(~trainNdx & ~intInd,child));
    end
end
hashTable.put(key,score);
end
