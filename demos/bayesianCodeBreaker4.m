% demo of Bayesian optimization for "code breaking"

%{
Consider a hidden "code" (sequence of letters) of length L, c(1:L),
where each element of the code is an integer in {1,..,A}.
We are allowed to generating query strings of length L, x(1:L), from the
same alphabet. The oracle function is the hamming distance
  f*(x) = sum_{l=1}^L delta(x(l) != c(l)) = sum_l d_l(x(l), c(l))
We want to solve the problem
  x*  = argmin_{x in A^L} f*(x)
using as few queries as possible. 

We will use Bayesian optimization for this. 
There are A^L possible functions.
If f(x) in {1,..,K} then we can represent p(f(x)) as a histogram
over K numbers, and hence the prior over functions as a row-stochastic
matrix of size A^L * K.


If the prior over f is uniform, the agent cannot beat brute force
enumeration. So instead we will assume the prior has the following
structure, which in this cases matches the true structure of f*
(shown below for L=2):
  

c1 x1 x2 c2
 \  /  \  /
   d1   d2
    \   /
      y

where
p(ci) is the (initially uniform) prior over letter i of the code  
p(di|ci,xi) = delta(di = (ci != xi)), di in {0,1}
p(y|d(1:L)) = delta(y = sum_l dl), y in {0, ..., L}

Hence p(f) is a uniform distribution over functions of the form
 f(x) = hammingDistance(x, c)
where we put a uniform prior over codes c

Note that the agent gets "partial credit" for its guess x,
in the form of a "distance to target" signal, rather than just 0-1
reward. This is the only way it can outperform brute force search.
For example, if we observe y=1 after guessing x=[1,2,1], we know that
 the posterior p(c|y,x) will put mass on all
strings that are edit distance 1 from x (namely: 221, 321, 111, 131, 122, 123)
This means we can restrict our search to radius 2 from x.

Note that even if the prior over codes is factored,
p(c) = prod_l p(cl), the posterior is completely correlated due to 
explaining away induced by y. Hence the posterior over functions is
represented by a single node f.

Note that although y is treated as a categorical variable, we can
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



 function [G, cnodes, xnodes, dnodes, ynode] = makePriorGraph(L)
    cnodes = (1:L);
    xnodes = (L+1):(2*L);
    dnodes = (2*L + 1):(3*L);
    ynode = 3*L + 1;
    nnodes = 3*L + 1;
    G = zeros(nnodes, nnodes);
    for i=1:L
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

  

    function CPTs = makeCodePriors(L, A, code)
        % CPTs{i} = p(ci) = prior over code letter i
        % set code(i)  = 0 if unknown (uniform prior for ci)
        % set code(i) in {1,..,A} to use delta function for that slot
        CPTs = cell(1, L);
        for i=1:L
            if code(i) > 0
                % delta function
                CPTs{i} = zeros(1, A);
                CPTs{i}(code(i)) = 1.0;
            else
                CPTs{i} = normalize(ones(1,A)); % uniform prior
            end
        end
    end

function model = makePriorBayesNet(L, A, codeCPTs)
    [G, cnodes, xnodes, dnodes, ynode] = makePriorGraph(L);
    nnodes = size(G,1);
    CPTs = cell(1, nnodes);
    for i=1:L
        CPTs{cnodes(i)} = codeCPTs{i};
        CPTs{xnodes(i)} = normalize(ones(1,A)); % will always be clamped
        CPTs{dnodes(i)} = makeDiffCPT(A);
    end
    CPTs{ynode} = makeSumCPT(L);
    nyvals = L+1;
    pgm = dgmCreate(G, CPTs);
    nnodes = size(G, 1);
    model = structure(pgm, nnodes, cnodes, xnodes, dnodes, ynode, L, A, nyvals);
end

 function postPgm = bayesianUpdate(model, x, y)
        clamped = zeros(1, model.nnodes);
        clamped(model.xnodes) = x;
        clamped(model.ynode) = y;
        % UNFINISHED
    end

    function bel = probYGivenX(x, model)
        % bel(y) = p(y | x)
        clamped = zeros(1, model.nnodes);
        clamped(model.xnodes) = x;
        bel = dgmInferQuery(model.pgm, [model.ynode], 'clamped', clamped);
    end


    function CPT = probY(model)
        A = model.A; L = model.L; K = model.nyvals;
        xs = ind2subv(A*ones(1,L), 1:(A^L)); % all possible queries
        CPT = zeros(A^L, K);
        for i=1:A^L
            bel = probYGivenX(xs(i,:), model);
            CPT(i, :) = bel.T(:);
        end
    end
        
 
 function e = expectedValueGivenX(probF, x, L, A)
        assert(L == length(x));
        vals = 0:L;
        ndx = subv2ind(A*ones(1,L), x);
        probF = reshape(probF, [A^L, L+1]);
        e = sum(probF(ndx, :) .* vals);
 end

    function e = expectedValuesAllX(probF, L, A)
       xs = ind2subv(A*ones(1,L), 1:A^L);
        e = zeros(1, A^L);
        for i=1:A^L
            e(i) = expectedValueGivenX(probF, xs(i,:), A, L);
        end
    end

    function [minimaStr, minimaNdx, minimaVals] = globalMinima(scores, L, A)
        % Return the set argmin_x score(x) =m*
        m = min(scores);
        minimaNdx = find(e == m);
        minimaStr = ind2subv(A*ones(1,L), minimaNdx);
        minimaVals = scores(minimaNdx);
    end

function h = hammingDistance(x, c)
    h = sum(x ~= c);
end

function h = hammingSimilarity(x, c)
    h = sum(x == c);
end
 
    function [y] = oracle(x)
        code = [1, 1, 1];
        y = hammingDistance(x, code);
    end

    function dispStrings(str, score)
        N = size(str, 1);
        for i=1:N
            x = str(i,:);
            y = oracle(x);
            fprintf(1, '%d ', x);
            fprintf(1, ': oracle() = %d', y);
            if ~isempty(score)
                fprintf(1, ', score()=%3.2f', score(i));
            end
            fprintf(1, '\n');
        end
    end


    function post = bayesianUpdateFlat(prior, x, y)
        L = length(x);
        lik = zeros(1, L+1);
        lik(y+1) = 1.0;
        priorFlat = reshape(prior, [A^L, L+1]);
        ndx = subv2ind(A*ones(1,L), x);
        postFlat = priorFlat;
        postFlat(ndx,:) = normalize(priorFlat(ndx,:) .* lik);
        post = reshape(postFlat, [A*ones(1,L), L+1]);
    end


% For debugging purposes, we check that the prior over f(x) has
% the expected values.

    function testOracle3()
        L = 3; A = 4;
    % First we use an oracle prior that has access to the true code.
    codePriors = makeCodePriors(L, A, [1,1,1]);
    priorPgm = makePriorBayesNet(L, A, codePriors);
    priorYflat = probY(priorPgm);
    Fprob = reshape(priorYflat, [A*ones(1,L), L+1]);
    %dispcpt(priorY)
    assert(approxeq(squeeze(Fprob(1,1,1,:)), [1 0 0 0]')) % 0 bits away 
    assert(approxeq(squeeze(Fprob(2,1,1,:)), [0 1 0 0]')) % 1 bits away 
    assert(approxeq(squeeze(Fprob(2,2,1,:)), [0 0 1 0]')) % 2 bits away 
    assert(approxeq(squeeze(Fprob(2,2,2,:)), [0 0 0 1]')) % 3 bits away 

    assert(expectedValueGivenX(Fprob, [1,1,1], A, L) == 0)
    assert(expectedValueGivenX(Fprob, [2,1,1], A, L) == 1)

    nyvals = L+1;
    Fmodel = structure(Fprob, L, A, nyvals);
    e = expectedValuesAllX(priorY, A, L);
    [bestStr, bestNdx, bestVals] = globalMinima(e, A, L);
    disp(['best strings for oracle prior'])
    dispStrings(bestStr, bestVals)
    end

    function testOracle2()
        L = 3; A = 4;
    % We use a semi-oracle prior that has access to the true code
    % for bits 1:2. So there are only 4 possible prior codes.
    codePriors = makeCodePriors(L, A, [1,1,0]);
    priorPgm = makePriorBayesNet(L, A, codePriors);
    priorYflat = probY(priorPgm);
    priorY = reshape(priorYflat, [A*ones(1,L), L+1]);
    %dispcpt(priorY)
    %{
    c*   x=111 211  221
    111  d=0   d=1  d=2
    112  d=1   d=2  d=3
    113  d=1   d=2  d=3
    114  d=1   d=2  d=3
    %}
    assert(approxeq(squeeze(priorY(1,1,1,:)), [0.25 0.75 0 0]')) 
    assert(approxeq(squeeze(priorY(2,1,1,:)), [0 0.25 0.75 0]')) 
    assert(approxeq(squeeze(priorY(2,2,1,:)), [0 0 0.25 0.75]')) 

    assert(expectedValueGivenX(priorY, [1,1,1], A, L) == 0.25*0 + 0.75*1)
    assert(expectedValueGivenX(priorY, [2,1,1], A, L) == 0.25*1 + 0.75*2)
    assert(expectedValueGivenX(priorY, [2,2,1], A, L) == 0.25*2 + 0.75*3)

    e = expectedValuesAllX(priorY, A, L);
    [bestStr, bestNdx, bestVals] = globalMinima(e, A, L);
    disp('best strings for oracle-2 prior')
    dispStrings(bestStr, bestVals)

    % The best strings are 111, 112, 113, 114
    % They all have the same expected value of 0.75
    % If we query 111, we discover f(111)=0 so the posterior collapses
    % to p(c=[111]) and hence x*=111.
    % If we query 112, 113 or 114, we discover f(q) > 0
    % so we are left with 3 candidates.

    queries = {[1,1,1], [1,1,2]};
    for i=1:length(queries)
        x = queries{i};
        bel = priorY;
        bel = bayesianUpdate(bel, x, oracle(x));
        e = expectedValuesAllX(bel, A, L);
        [bestStr, bestNdx, bestVals] = globalMinima(e, A, L);
        disp(['best strings given query ', num2str(x), ' and oracle-2'])
        dispStrings(bestStr, bestVals)
    end

    end


    function testOracle1()
        L = 3; A = 4;
    % Now we use a semi- oracle prior that has access to the true code
    % for bits 1. So there are  16 possible prior codes.
    codePriors = makeCodePriors(L, A, [1,0,0]);
    priorPgm = makePriorBayesNet(L, A, codePriors);
    priorYflat = probY(priorPgm);
    priorY = reshape(priorYflat, [A*ones(1,L), L+1]);

    e = expectedValuesAllX(priorY, A, L);
    [bestStr, bestNdx, bestVals] = globalMinima(e, A, L);
    disp('best strings for oracle-1 prior')
    dispStrings(bestStr, bestVals)

    queries = {[1,1,1], [1,2,2]};
    for i=1:length(queries)
        x = queries{i};
        bel = priorY;
        bel = bayesianUpdate(bel, x, oracle(x));
        e = expectedValuesAllX(bel, A, L);
        [bestStr, bestNdx, bestVals] = globalMinima(e, A, L);
        disp(['best strings given query ', num2str(x), ' and oracle-1'])
        dispStrings(bestStr, bestVals)
    end
    end

%% Main

testOracle1()

end
