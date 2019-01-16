% demo of Bayesian optimization for "code breaking"

%{
Consider a hidden "code" (sequence of letters) of length L, c(1:L),
where each element of the code is an integer in {1,..,A}.
We are allowed to generating query strings of length L, x(1:L), from the
same alphabet. The oracle function is the hamming distance
  f*(x) = sum_{l=1}^L delta(x(l) != c(l)) = sum_l d_l(x(l), c(l))
We want to solve the problem
  x*  = argmin_{x in A^L} f*(x)
using as few queries as possible. We will use Bayesian optimization for
this. We assume the "code breaking agent" uses the following model for the
surrogate y=f(x), illustrated for the case where L=2:
  
   cprior
  /      \
c1 x1 x2 c2
 \  /  \  /
   d1   d2
    \   /
       y

where
p(cprior) is an (initially uniform) prior over codes
p(ci) is the marginal over letter i of the code  
p(di|ci,xi) = delta(di = (ci != xi)), di in {0,1}
p(y|d(1:L)) = delta(y = sum_l dl), y in {0, ..., L}

Hence

y(x) = f(x) = sum_{c(1:L)} delta(y|d) delta(d|c,x) p(c)
E[y | x] = sum_c p(c) sum_{l} d_l(x_l, c_l) = sum_l E_{c_l} d_l(x_l,c_l)

Note that the agent gets "partial credit" for its guess x,
in the form of a "distance to target" signal, rather than just 0-1
reward. This is the only way it can outperform brute force search.
For example, if we observe y=2 after guessing x, we know that
c is distance 2 away from x, so the posterior p(c|y,x) will put mass on all
strings that are edit distance 2 from x. This means we can restrict our
search to radius 2 from x.

Note that even if the prior over codes is factored,
p(c) = prod_l p(cl), the posterior is completely correlated due to 
explaining away induced by y. If we use a factorized posterior,
we would lose this structure. We could potentially approximate the
posterior using beam search or sampling, although in this demo we use exact
 inference. (This costs A^L at each step; we set A=4 (cf DNA strings) and 
L=3, so we want to crack the code in fewer than 4^3=64 trials.)
To represent the correlated posterior, we introduce the cprior node.
This lets us perform sequential Bayesian updating.

Note also that although y is treated as a categorical variable, we can
encode metric structure into the problem by the way we construct p(y|d).
(We could potentially improve inference efficiency by exploiting this
structure explicitly.)

Let the posterior belief state at time t be denoted by
pt(.) = p(.|D(t-1)), where D(t-1) = {(xn, yn): n=1:t-1} is all the evidence
obtained so far. The agent can use this to decide what strings to query next
 by maximizing the acquisition function
  xt = argmax_{x in A^L} at(x)
We will use expected improvement, which is given by the following
(for some  threshold tau, eg the value of the incumbent):
  EIt(x; tau) = E_y [(y - tau) * ind(y > tau)] 
    = sum_{v=0}^L pt(y=v|x) * (v-tau) * ind(v > tau)
where pt(y|x) is the posterior predictive over outcomes.

Let bt be the best string seen so far (the incumbent).
We plot f*(bt) vs time t for different algorithms:
- BO with enumerative acq solver  
- BO with random acq solver (budget of B guesses)
- Random f* solver

%}

function bayesianCodeBreaker()

function h = hammingDistance(x, c)
    h = sum(x ~= c);
end

 function [G, cnodes, xnodes, dnodes, ynode, cpnode] = makeGraph(L)
    cpnode = 1;
    cnodes = 1+ (1:L);
    xnodes = 1+ (L+1):(1+ 2*L);
    dnodes = 1+ (2*L + 1):(1+ 3*L);
    ynode = 1+ 3*L + 1;
    nnodes = 1+ 3*L + 1;
    G = zeros(nnodes, nnodes);
    for i=1:L
        G(cpnode, cnodes(i)) = 1;
        G(cnodes(i), dnodes(i))=1;
        G(xnodes(i), dnodes(i))=1;
    end
    G(dnodes, ynode) = 1;
 end

function CPT = makeDiffCPT(A)
    % CPT(c,x,d) = delta(d = (c != x))
    % Note that event d=0 is encoded by 1, and d=1 by 2.
    CPT = zeros(A, A, 2);
    for c=1:A
        for x=1:A
            if c==x
                CPT(c,x,1) = 1.0;
            else
                CPT(c,x,2) = 1.0;
            end
        end
    end
end

    function CPT = makeSumCPT(L)
        % CPT(dnode1,...,dnodeL,y) = delta(y = sum_l dnodel)
        % The event y=0 is encoded by 1, ..., y=L is encoded by L+1
        CPT = zeros(2^L, L+1);
        bits = ind2subv(2*ones(1,L), 1:2^L)-1; % binary values for dnodes(1:L)
        bitsum = sum(bits, 2); % sum over columns
        %ndx = subv2ind([2^L, L+1], [bits bitsum]);
        %CPT(bits+1, bitsum+1) = 1.0;
        %CPT(ndx) = 1.0;
        for i=1:2^L
            CPT(i, bitsum(i)+1) = 1.0;
        end
        CPT = reshape(CPT, [2*ones(1,L), L+1]);
    end

    function CPT = makeMarginalCodeCPT(A, L, j)
        % CPT(codevec, cj) = sum_c delta(cj = codevec(j))
        CPT = zeros(1,A);
        codevec = ind2subv(A*ones(1,L),A^L);
        for i=1:A^L
            CPT(i, codevec(j)) = 1.0;
        end
    end

function model = makeBayesNet(L, A, code)
    [G, cnodes, xnodes, dnodes, ynode, cpnode] = makeGraph(L);
    nnodes = size(G,1);
    CPTs = cell(1, nnodes);
    CPTs{cpnode} = zeros(1, A^L);
    CPTs{cpnode}(code) = 1.0;
    for i=1:L
        %CPTs{cnodes(i)} = normalize(ones(1,A)); % uniform prior
        CPTs{cnodes(i)} = makeMarginalCodeCPT(A, L, i);
        CPTs{xnodes(i)} = normalize(ones(1,A)); % will always be clamped
        CPTs{dnodes(i)} = makeDiffCPT(A);
    end
    CPTs{ynode} = makeSumCPT(L);
    pgm = dgmCreate(G, CPTs);
    nnodes = size(G, 1);
    model = structure(pgm, nnodes, cnodes, xnodes, dnodes, ynode, cpnode, A, L);
end

    function bel = postPredGivenX(x, model)
        % post(y) = p(y | x)
        clamped = zeros(1, model.nnodes);
        %clamped(model.cnodes) = c;
        clamped(model.xnodes) = x;
        bel = dgmInferQuery(model.pgm, [model.ynode], 'clamped', clamped);
    end

    function post = postPred(model)
        xs = ind2subv(A*ones(1,L), 1:(A^L)); % all possible queries
        post = zeros(A^L, L+1);
        for i=1:A^L
            bel = postPredGivenX(xs(i,:), model);
            post(i, :) = bel.T(:);
        end
    end
        
 
L = 3;
A = 4;
code = [1,2,3];
model = makeBayesNet(L, A, code);
xs = ind2subv(A*ones(1,L), 1:(A^L));
post = postPredGivenC(model);
dispcpt(post)


end
