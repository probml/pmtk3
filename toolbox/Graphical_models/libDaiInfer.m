function postQuery = libDaiInfer(model, queryVars, visVars, visVals)

if nargin == 0; runTest(); return; end

tic
factors = model.Tfac;
if nargin > 2
    %% Condition on the evidence
    for i=1:numel(factors)
        localVars = intersect(factors{i}.domain, visVars);
        if isempty(localVars)
            continue;
        end
        localVals  = visVals(lookupIndices(localVars, visVars));
        factors{i} = tabularFactorSlice(factors{i}, localVars, localVals);
    end
end
factors = filterCell(factors, @(f)~isempty(f.domain)); % remove empty factors
psi = cellfuncell(@convertToLibFac, factors);
[logZ, q, md, qv, qf] = dai(psi, 'JTREE', '[updates=HUGIN]');

if numel(queryVars) == 1
    postQuery = convertToPmtkFac(qv{queryVars});
else % search q
    ndx = find(cellfun(@(f)issubset(queryVars, f.Member+1), q), 1, 'first');
    if ~isempty(ndx)
        postQuery = convertToPmtkFac(q{ndx}); 
    else % out of clique query
        [intersectSize, ndx] = max(cellfun(@(f)numel(intersect(queryVars, f.Member+1)), q));
        if intersectSize > 1
           largestFac = convertToPmtkFac(q{ndx}); 
           missing = setdiff(queryVars, largestFac.domain); 
           otherFacs = cellfuncell(@convertToPmtkFac, qv(missing));
           postQuery = tabularFactorNormalize(tabularFactorMultiply([{largestFac}; otherFacs]));
        else % just multiply together all of the marginals
            postQuery = tabularFactorNormalize(tabularFactorMultiply(cellfuncell(@convertToPmtkFac, qv(queryVars))));
        end
    end
end
toc



test = true;
if test
    if nargin < 3, visVars = []; visVals = []; end
    tic
    postQueryTest = variableElimination(model, queryVars, visVars, visVals);
    toc
    assert(approxeq(postQuery.T, postQueryTest.T));
    assert(isequal(postQuery.domain, postQueryTest.domain));
    assert(isequal(postQuery.sizes, postQueryTest.sizes));
end


end


function mfac = convertToPmtkFac(lfac)
    mfac = tabularFactorCreate(lfac.P, lfac.Member+1); 
end


function lfac = convertToLibFac(mfac)
lfac.Member = mfac.domain - 1;
lfac.P = mfac.T;
end


function runTest()


alarm = loadData('alarmNetwork');
CPT = alarm.CPT;
G   = alarm.G; 
n   = numel(CPT); 
Tfac = cell(n, 1); 
for i=1:numel(CPT)
    family = [parents(G, i), i];
    Tfac{i} = tabularFactorCreate(CPT{i}, family); 
end
domain = 1:n;
model = structure(Tfac, G, domain); 
%% Try some arbitrary queries 
p1_10Given13eq2 = libDaiInfer(model, 1:10, 13, 2); 
p33 = libDaiInfer(model, 33);


end