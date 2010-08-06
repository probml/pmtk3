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
%%
[maxIter, tol, lambda, convFn]  = process_options(varargin, ...
    'maxIter'       , 100  , ...
    'tol'           , 1e-3 , ...
    'dampingFactor' , 0.5  , ...
    'convFn'        , []);
%%
Tfac            = cg.Tfac;
nfacs           = numel(Tfac); 
[nbrs, sepSets] = computeNeighbors(cg); 
G               = cg.G; 
M               = initializeMessages(sepSets, cg.nstates);
nmsg            = sum(G(:)); 
Q               = initPriorityQueue(Tfac, G);                                
[ii, jj]        = find(G);    
T               = sparse(ii, jj, eps, nfacs^2, nfacs^2, nmsg^2); % total residuals
tndx            = @(a, b, c)Tindexer(a, b, c, size(T), size(Q)); % indexer into T
computeMsg      = @(a, b, M)computeMessage(a, b, M, Tfac, nbrs, sepSets, lambda);
all             = 1:nmsg; 
iter            = 1; 
counter         = 0; 
converged       = false; 
while ~converged && iter < maxIter
    
    Mold                 = M; 
    [Q, b, c]            = dequeue(Q); 
    [mbc, rdamp]         = computeMsg(b, c, M); 
    Q                    = enqueue(Q, b, c, rdamp); % see alg2 note on damping
    r                    = computeResidual(Mold{b, c}, mbc); 
    M{b, c}              = mbc; 
    T(tndx(all, all, c)) = eps;        
    ndx                  = tndx(b, c, all); 
    T(ndx)               = T(ndx) + r; 
    Nc                   = setdiffPMTK(nbrs{c}, b);
    for d = Nc
        v = sum(T(tndx(all, c, d))); 
        enqueue(Q, c, d, v); 
    end
    
    counter = counter + 1; 
    if counter == nmsg 
       counter = 0;  
       iter    = iter + 1; 
       if ~isempty(convFn)
           convFn(Mold, M); 
       end
    end
    converged = max(nonzeros(Q)) < tol; 
    
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
% see eq 13 for init
%%
nfacs   = numel(Tfac); 
msgNdx  = rowvec(find(G)); 
nmsg    = numel(msgNdx); 
Q       = sparse([], [], [], nfacs, nfacs, nmsg);
for ndx = msgNdx
    [c, d] = ind2sub([nfacs, nfacs], ndx); %#ok
    tc     = Tfac{c}.T(:);
    u      = normalize(ones(numel(tc), 1));
    Q(ndx) = norm(log(tc + eps) - log(u + eps), inf);
end
end

function Q = enqueue(Q, a, b, v)
%% enqueue a message (index) from a to b with priority v
% lazy - just store the priority
Q(a, b) = v; 
end

function [Q, a, b] = dequeue(Q)
%% dequque the message (index) with the highest priority
ndx    = argmax(Q); 
Q(ndx) = 0; 
a      = ndx(1); 
b      = ndx(2); 
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
mbc     = tabularFactorConvexCombination(mbcFull, mbcOld, lambda); 
r       = computeResidual(mbcFull, mbc);

end

function ndx = Tindexer(a, b, c, tsz, qsz)
%% Compute the linear index into T corresponding to 'T(ab, bc)'
%%
na = numel(a);
nb = numel(b);
nc = numel(c); 
n  = max([na, nb, nc]); 
if n > 1
   if na == 1
       a = repmat(a, 1, n); 
   end
   if nb == 1
       b = repmat(b, 1, n); 
   end
   if nc == 1
       c = repmat(c, 1, n);
   end
end
ndx = sub2ind(tsz, sub2ind(qsz, a, b), sub2ind(qsz, b, c)); 
end