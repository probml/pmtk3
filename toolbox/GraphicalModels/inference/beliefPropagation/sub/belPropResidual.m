function [bels, converged] = belPropResidual(cg, varargin)
%% Belief propagation using the dynamic update schedule of Sutton & McCallum
% Messages are passed according to a dynamcially updated priority queue,
% ordered by *estimates* of the message residuals. Sutton &
% McCullum call this RBP0L, (residual belief propagation with lookahead 0).
%
% See beliefPropagation
%% Reference
% @inproceedings{Sutton07,
% author = "C. Sutton and A. McCallum",
% title = {{Improved Dynamic Schedules for Belief Propagation}},
% year = 2007,
% booktitle = uai
% http://www.cs.umass.edu/~mccallum/papers/rbp0-uai07.pdf
%% This is experimental code and may be buggy
%
%%

% This file is from pmtk3.googlecode.com

[maxIter, tol, lambda, convFn]  = process_options(varargin, ...
    'maxIter'       , 100  , ...
    'tol'           , 1e-3 , ...
    'dampingFactor' , 0.5  , ...
    'convFn'        , []);
%%
Tfac            = cg.Tfac;
nfacs           = numel(Tfac); 
[nbrs, sepSets] = computeNeighbors(cg); 
G               = mkSymmetric(cg.G); 
M               = initializeMessages(G, sepSets, cg.nstates);
nmsg            = sum(G(:)); 
msgNdx          = find(G); 
Q               = initPriorityQueue(Tfac, G);                                   
T               = sparse([], [], [], nfacs.^3, 1, nmsg.^2);         % total residuals
tndx            = @(a, b, c)Tindexer(a, b, c, repmat(nfacs, 1, 4)); % indexer into T
computeMsg      = @(a, b, M)computeMessage(a, b, M, Tfac, nbrs, sepSets, lambda);
ALL             = 1:nfacs; 
iter            = 1; 
counter         = 0; 
converged       = false; 
updateCounter   = zeros(nfacs, nfacs); 
while ~converged && iter < maxIter
    
    Mold                 = M; 
    [Q, b, c]            = dequeue(Q); 
    [mbc, rdamp]         = computeMsg(b, c, M);
    Q(b, c)              = rdamp; % enqueue  see alg2 note on damping
    r                    = computeResidual(Mold{b, c}, mbc); 
    M{b, c}              = mbc; 
    updateCounter(b, c)  = updateCounter(b, c) + 1; 
    T(tndx(ALL, ALL, c)) = eps;        
    ndx                  = tndx(b, c, ALL); 
    T(ndx)               = T(ndx) + r; 
    Nc                   = setdiffPMTK(nbrs{c}, b);
    for d = Nc
        v = sum(full(T(tndx(ALL, c, d)))); 
        Q(c, d) = v; % enqueue
    end
    %%
    counter = counter + 1; 
    if counter == nmsg 
       counter = 0;  
       iter    = iter + 1;
       if ~isempty(convFn)
           convFn(Mold, M); 
       end
       converged = all(updateCounter(msgNdx)) && ... 
           all(cellfun(@(O, N)approxeq(O.T, N.T, tol), Mold(msgNdx), M(msgNdx)));     
    end
    
end

%% final beliefs
bels = cell(nfacs, 1); 
for a = 1:nfacs
    psi     = tabularFactorMultiply([Tfac(a); M(nbrs{a}, a)]);
    bels{a} = tabularFactorNormalize(psi); 
end
end

function r = computeResidual(old, new)
%% Compute the residual between the old and new message
% see eq 6 in reference above
r = norm(log(new.T(:) + eps) - log(old.T(:) + eps), inf); 
end

function Q = initPriorityQueue(Tfac, G)
%% Initialize the (lazy) 'priority queue'
% We do linear search O(n) to dequeue, but get constant time insertions 
% and priority updates, while avoiding the overhead of a full data structure. 
% see eq 13 for init
%%
nfacs    = numel(Tfac); 
msgNdx   = rowvec(find(G)); 
nmsg     = numel(msgNdx); 
[ii, jj] = find(G);
Q        = sparse(ii, jj, eps, nfacs, nfacs, nmsg);
for ndx = msgNdx
    [c, d] = ind2sub([nfacs, nfacs], ndx); %#ok
    tc     = Tfac{c}.T(:);
    u      = normalize(ones(numel(tc), 1));
    Q(ndx) = norm(log(tc + eps) - log(u + eps), inf);
end
end

function [Q, a, b] = dequeue(Q)
%% dequque the message (index) with the highest priority
ndx     = argmax(Q); 
a       = ndx(1); 
b       = ndx(2); 
assert(a ~= b); 
Q(a, b) = eps; % reserve 0 for invalid portions of the matrix 
end

function [mbc, r] = computeMessage(b, c, messages, Tfac, nbrs, sepSets, lambda)
%% Compute a message from factor b to factor c 
% r is the residual between the full and damped update
% using equation 4
%%
N       = setdiffPMTK(nbrs{b}, c); 
psi     = tabularFactorMultiply([Tfac(b); messages(N, b)]);
mbcOld  = messages{b, c}; 
mbcFull = tabularFactorMarginalize(psi, sepSets{b, c}); 
mbcFull = tabularFactorNormalize(mbcFull); 
if lambda
    mbc  = tabularFactorConvexCombination(mbcFull, mbcOld, lambda); 
    r    = max(eps, computeResidual(mbcFull, mbc));
else
    mbc = mbcFull;  
    r   = eps;
end
end

function ndx = Tindexer(a, b, c, sz)
%% Compute the linear index into T corresponding to 'T(ab, bc)'
na = numel(a);
nb = numel(b);
nc = numel(c); 
n  = max([na, nb, nc]); 
if n > 1
   if na == 1, a = repmat(a, 1, n);    end
   if nb == 1, b = repmat(b, 1, n);    end
   if nc == 1, c = repmat(c, 1, n);    end
end

ndx = sub2ind(sz, a, b, c); 
end
