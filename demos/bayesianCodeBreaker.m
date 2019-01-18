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
  

x1  x2   c
 \   |   /
    \   /
      y

where
p(c) is the (initially uniform) prior over codes 
p(y|x(1:L), c) = delta(y = hammingDistance(x,c)), y in {0, ..., L}


Note that the agent gets "partial credit" for its guess x,
in the form of a "distance to target" signal, rather than just 0-1
reward. This is the only way it can outperform brute force search.
For example, if we observe y=1 after guessing x=[1,2,1], we know that
 the posterior p(c|y,x) will put mass on all
strings that are edit distance 1 from x (namely: 221, 321, 111, 131, 122, 123)
This means we can restrict our search to radius 2 from x.


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
  EIt(x; tau) = E_y [(tau - y) * ind(y < tau)] 
    = sum_{v=0}^L pt(y=v|x) * (tau-v) * ind(v < tau)
where pt(y|x) is the posterior predictive over outcomes.

Let bt be the best string seen so far (the incumbent).
We plot f*(bt) vs time t for different algorithms:
- BO with enumerative acq solver  
- BO with random acq solver (budget of B guesses)
- Random f* solver

%}




function bayesianCodeBreaker()


%% Bayes net code
 function [G, cnode, xnodes, ynode] = makeBayesNetGraph(L)
    xnodes = (1:L);
    cnode = L+1;
    ynode = L+2;
    nnodes = L+2;
    G = zeros(nnodes, nnodes);
    G(xnodes, ynode) = 1;
    G(cnode, ynode) = 1;
 end



    function prior = makeCodePriors(L, A, code)
        % set code(i)  = 0 if unknown (uniform prior for ci)
        % set code(i) in {1,..,A} to use delta function for that slot
        cs = ind2subv(A*ones(1,L), 1:A^L);
        prior = ones(1, A^L);
        for i=1:A^L
            for l=1:L
             if (code(l) > 0) && (cs(i,l) ~= code(l)) 
                    prior(i) = 0;
             end
            end
        end
        prior = normalize(prior);
    end

    function CPT = makeHammingCPT(L, A)
        % CPT(x1,...,xL,c,y)
        nstr = A^L;
        CPT = zeros(nstr, nstr, L+1);
        sz = A*ones(1,L);
        for xndx = 1:nstr
            x = ind2subv(sz, xndx);
            for cndx = 1:nstr
                c = ind2subv(sz, cndx);
                h = hammingDistance(x, c);
                y = h + 1;
                CPT(xndx, cndx, y) = 1.0;
            end
        end
        CPT = reshape(CPT, [sz nstr L+1]);
    end

function pgm = makeBayesNet(L, A, codePrior)
    [G, cnode, xnodes, ynode] = makeBayesNetGraph(L);
    nnodes = size(G,1);
    CPTs = cell(1, nnodes);
    CPTs{cnode} = codePrior;
    for i=1:L
        CPTs{xnodes(i)} = normalize(ones(1,A)); % will always be clamped
    end
    CPTs{ynode} = makeHammingCPT(L, A);
    nyvals = L+1;
    dgm = dgmCreate(G, CPTs);
    nnodes = size(G, 1);
    pgm = structure(dgm, nnodes, cnode, xnodes, ynode, L, A, nyvals);
end

 function [pgm, codePost] = bayesianUpdate(pgm, x, y)
     L  = pgm.L; A = pgm.A; 
        clamped = zeros(1, pgm.nnodes);
        clamped(pgm.xnodes) = x;
        clamped(pgm.ynode) = y+1; % since domain is {1,2,...,K}
        nodeBels = dgmInferNodes(pgm.dgm, 'clamped', clamped);
        codeBel = nodeBels(pgm.cnode);
        codePost = codeBel{1}.T(:)';
        pgm = makeBayesNet(L, A, codePost);
    end

    function bel = probYGivenX(pgm, x)
        % bel(y) = p(y | x)
        clamped = zeros(1, pgm.nnodes);
        clamped(pgm.xnodes) = x;
        bel = dgmInferQuery(pgm.dgm, [pgm.ynode], 'clamped', clamped);
    end


    function CPT = probYGivenAllX(pgm)
        A = pgm.A; L = pgm.L; K = pgm.nyvals;
        xs = ind2subv(A*ones(1,L), 1:(A^L)); % all possible queries
        CPT = zeros(A^L, K);
        for i=1:A^L
            bel = probYGivenX(pgm, xs(i,:));
            CPT(i, :) = bel.T(:);
        end
    end
        
%% Surrogate function code


    function Fmodel = makeSurrogateFromPgm(pgm)
        L = pgm.L; A = pgm.A;
        priorYflat = probYGivenAllX(pgm);
        Fprob = reshape(priorYflat, [A*ones(1,L), L+1]);
        Fdomain = ind2subv(A*ones(1,L), 1:A^L); Frange = 0:L;
        Fmodel = structure(Fprob, L, A, Fdomain, Frange);
    end


     function e = expectedValue(Fmodel, x)
            L = Fmodel.L; A = Fmodel.A; 
            assert(L == length(x));
            ndx = subv2ind(A*ones(1,L), x);
            prob = reshape(Fmodel.Fprob, [A^L, length(Fmodel.Frange)]);
            e = sum(prob(ndx, :) .* Fmodel.Frange);
     end

  function e = expectedImprovement(Fmodel, x, thresh)
            L = Fmodel.L; A = Fmodel.A; 
            assert(L == length(x));
            ndx = subv2ind(A*ones(1,L), x);
            prob = reshape(Fmodel.Fprob, [A^L, length(Fmodel.Frange)]);
            probGivenX = prob(ndx, :);
            fn = @(y) max(0, (thresh-y)); % if y < thresh, we improve
            ys = Fmodel.Frange;
            e = 0;
            for i=1:length(ys)
                e = e + probGivenX(i)*fn(ys(i));
            end
     end

    function dispSurrogate(Fmodel, trueCode, varargin)
        [str, doPlot, drawLines, incumbentVal, showAll] = process_options(varargin, ...
            'str', '', 'doPlot', true, 'drawLines', true, ...
            'incumbentVal', 0, 'showAll', false);
        L = Fmodel.L; A = Fmodel.A;
    xs = Fmodel.Fdomain;
    e = applyFun(xs, @(x) expectedValue(Fmodel, x));
    eic = applyFun(xs, @(x) expectedImprovement(Fmodel, x, incumbentVal));
    o = applyFun(xs, @(x) hammingDistance(x, trueCode));
    [ndx] = argmaxima(eic);
    nmin = length(ndx);
    if doPlot
        Nstr = length(e); 
        figure; 
        if drawLines
            plot(1:Nstr, e, 'r-', 1:Nstr, eic, 'g--', 1:Nstr, o, 'b:', 'linewidth', 2);
        else
            plot(1:Nstr, e, 'rx', 1:Nstr, eic, 'g*', 1:Nstr, o, 'bo', 'linewidth', 2);
        end
        set(gca, 'ylim', [-0.1 L+0.1]);
        legend('expected', 'eic', 'true', 'location', 'southeast')
        title(str);
        set(gca, 'xtick', ndx);
        args = cell(1, nmin);
        for i=1:nmin
            args{i} = num2str(xs(ndx(i),:));
        end
        xticklabelRot(args, 45, 8);
    end

    if showAll
        ndx = 1:length(o);
    else
        [ndx] = argmaxima(eic);
    end
    nmin = length(ndx);
    separator = repmat('|', nmin, 1);
    disp(str)
    disp('args, expected, eic, objective');
    evals = e(ndx); eicvals = eic(ndx); ovals = o(ndx);
    disp([num2str(xs(ndx,:)), separator, num2str(evals(:)), ...
            separator, num2str(eicvals(:)), separator, num2str(ovals(:))])
     
    end



%% Generic code
    function vals = applyFun(args, fn)
        % vals(i) = fn(args(i,:))
        nrows = size(args, 1);
        vals = zeros(1, nrows);
        for i=1:nrows
            vals(i) = fn(args(i,:));
        end
    end
        

    function [ndx, vals] = argminima(scores)
        m = min(scores);
        ndx = find(scores==m);
        vals = scores(ndx); % N copies of the value m
    end

 function [ndx, vals] = argmaxima(scores)
        m = max(scores);
        ndx = find(scores==m);
        vals = scores(ndx); % N copies of the value m
    end


    function h = hammingDistance(x, c)
        h = sum(x ~= c);
    end

 

%% Testing code

    function testOraclePrior3()
        L = 3; A = 4;
    % First we use an oracle prior that has access to the true code.
    code = [1,1,1];
    codePrior = [1,1,1];
    codePriors = makeCodePriors(L, A, codePrior);
    priorPgm = makeBayesNet(L, A, codePriors);
    Fmodel = makeSurrogateFromPgm(priorPgm);
    priorY = Fmodel.Fprob;
    assert(approxeq(squeeze(priorY(1,1,1,:)), [1 0 0 0]')) % 0 bits away 
    assert(approxeq(squeeze(priorY(2,1,1,:)), [0 1 0 0]')) % 1 bits away 
    assert(approxeq(squeeze(priorY(2,2,1,:)), [0 0 1 0]')) % 2 bits away 
    assert(approxeq(squeeze(priorY(2,2,2,:)), [0 0 0 1]')) % 3 bits away   
    assert(expectedValue(Fmodel, [1,1,1]) == 0)
    assert(expectedValue(Fmodel, [2,1,1]) == 1)
    dispSurrogate(Fmodel, code, 'str', 'oracle3', 'doPlot', false);
    end

    function testOraclePrior2()
        L = 3; A = 4;
    % We use a semi-oracle prior that has access to the true code
    % for bits 1:2. So there are only 4 possible prior codes.
    code = [1,1,1];
    codePrior = [1,1,0];
    codePriors = makeCodePriors(L, A, codePrior);
    priorPgm = makeBayesNet(L, A, codePriors);
    Fmodel = makeSurrogateFromPgm(priorPgm);
    priorY = Fmodel.Fprob;
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
    assert(expectedValue(Fmodel, [1,1,1]) == 0.25*0 + 0.75*1)
    assert(expectedValue(Fmodel, [2,1,1]) == 0.25*1 + 0.75*2)
    assert(expectedValue(Fmodel, [2,2,1]) == 0.25*2 + 0.75*3)
    
    % The prior says that the only optima can be 111, 112, 113, or 114.
    dispSurrogate(Fmodel, code, 'str', 'oracle2', 'doPlot', false)
    
  
    % If we query 112, we discover f(112)=1, so we still have 3 candidates
    x=[1,1,2]; y = hammingDistance(x, code);
    postPgm = bayesianUpdate(priorPgm, x, y);
    Fmodel = makeSurrogateFromPgm(postPgm);
    dispSurrogate(Fmodel, code, 'str', 'oracle2+f(112)', 'doPlot', false)
    
  
      % If we query 111, we discover f(111)=0 and we're done!
    x=[1,1,1]; y = hammingDistance(x, code);
    postPgm = bayesianUpdate(priorPgm, x, y);
    Fmodel = makeSurrogateFromPgm(postPgm);
    dispSurrogate(Fmodel, code, 'str', 'oracle2+f(111)', 'doPlot', false)
  
    end


    function testOraclePrior1()
        L = 3; A = 4;
    % Now we use a semi- oracle prior that has access to the true code
    % for bits 1. So there are  16 possible prior codes.
    code = [1,1,1];
    codePrior = [1,0,0];
    codePriors = makeCodePriors(L, A, codePrior);
    priorPgm = makeBayesNet(L, A, codePriors);
    Fmodel = makeSurrogateFromPgm(priorPgm);
    dispSurrogate(Fmodel, code, 'str', 'oracle1', 'doPlot', false)

    % The prior allows for 4^2=16 possible codes

    % If we query 112, we discover f(112)=1, so we still have 15 candidates
    x=[1,1,2]; y = hammingDistance(x, code);
    postPgm = bayesianUpdate(priorPgm, x, y);
    Fmodel = makeSurrogateFromPgm(postPgm);
    incumbent = x; incumbentVal = y;
    dispSurrogate(Fmodel, code, 'str', 'oracle1+f(112)', 'doPlot',false, ...
        'incumbentVal', y)
    
      % If we query 111, we discover f(111)=0 and we're done!
    x=[1,1,1]; y = hammingDistance(x, code);
    postPgm = bayesianUpdate(priorPgm, x, y);
    Fmodel = makeSurrogateFromPgm(postPgm);
    dispSurrogate(Fmodel, code, 'str', 'oracle1+f(111)', 'doPlot', false)
    end

    function saveFigure(fname)
         printFolder = '/home/kpmurphy/github/pmtk3/figures';
         format = 'png';
         fname = sprintf('%s/%s.%s', printFolder, fname, format);
        fprintf('printing to %s\n', fname);
         print(gcf, '-dpng', fname);
    end

 function testUnifPrior()
   
        L = 3; A = 4;
    % Uniform prior means 4^3=64 codes.
    code = [1,1,1];
    codePrior = [0,0,0];
    codePriors = makeCodePriors(L, A, codePrior);
    priorPgm = makeBayesNet(L, A, codePriors);
    Fmodel = makeSurrogateFromPgm(priorPgm);
    incumbentVal = max(Fmodel.Frange);
    dispSurrogate(Fmodel, code, 'str', 'unif', 'incumbentVal', ...
        incumbentVal, 'drawLines', false)
    saveFigure('codeBreaker1');

    % If we query 112, we discover f(112)=1, 
    % so the posterior is 1 away from 112 and has 9 strings,
    % each with prob 1/9=0.111: 
    % 111, 113, 114,  122, 132, 142,  212, 312, 412
    %
    x=[1,1,2]; y = hammingDistance(x, code);
    incumbentVal = y;
    [postPgm, postCodes] = bayesianUpdate(priorPgm, x, y);
    Fmodel = makeSurrogateFromPgm(postPgm);
    dispSurrogate(Fmodel, code, 'str', 'f(112)', 'incumbentVal', ...
        incumbentVal, 'drawLines', false);
    saveFigure('codeBreaker2');
 
    % If we now query 114, we discover f(114)=1, 
    % so the posterior is 1 away from 112 and 114 and has 2 strings,
    % each with prob 1/2=0.5: 
    % 111, 113
    %
    x=[1,1,4]; y = hammingDistance(x, code);
    incumbentVal = min(y, incumbentVal);
    [postPgm, postCodes] = bayesianUpdate(postPgm, x, y);
    Fmodel = makeSurrogateFromPgm(postPgm);
    dispSurrogate(Fmodel, code, 'str', 'f(112),f(114)', 'incumbentVal', ...
        incumbentVal, 'drawLines', false);
    saveFigure('codeBreaker3');
    
    x=[1,1,3]; y = hammingDistance(x, code);
    incumbentVal = min(y, incumbentVal);
    [postPgm, postCodes] = bayesianUpdate(postPgm, x, y);
    Fmodel = makeSurrogateFromPgm(postPgm);
    dispSurrogate(Fmodel, code, 'str', 'f(112),f(114),f(113)', 'incumbentVal', ...
        incumbentVal, 'drawLines', false);
    saveFigure('codeBreaker4');
 
    end

%% Main

%testOraclePrior3()
%testOraclePrior2()
%testOraclePrior1()
testUnifPrior()

end
