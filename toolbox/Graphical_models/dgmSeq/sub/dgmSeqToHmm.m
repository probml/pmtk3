function hmm = dgmSeqToHmm(dgmSeq)
%% Convert a dgmSeq to an hmm


intra = dgmSeq.intra; 
inter = dgmSeq.inter; 
slice1CPDs   = dgmSeq.slice1CPDs;
slice2CPDs   = dgmSeq.slice2CPDs;
emission = dgmSeq.emission; 

intraH  = intra(1:end-1, 1:end-1); 
interH  = inter(1:end-1, 1:end-1); 
nHnodes = size(intra, 1) - 1; 
G2T     = zeros(2*nHnodes); 
G2T(1:nHnodes, 1:nHnodes) = intraH; 
G2T(1:nHnodes, nHnodes+1:end) = interH; 

factors = cpds2Factors([slice1CPDs(:); slice2CPDs(:)], G2T); 
ns    = rowvec(cellfun(@(c)c.sizes(end), factors(1:nHnodes))); 
Qh    = prod(ns); 
piFac = tabularFactorMultiply(factors(1:nHnodes)); 
Afac  = tabularFactorMultiply(factors(nHnodes+1:end)); 

pi    = piFac.T(:); 
A     = reshape(Afac.T, Qh, Qh); 

if isfield(emission, 'T')
    
    Tsmall   = tabularFactorCreate(emission.T, [parents(intra, nHnodes), nHnodes]); 
    sz       = Tsmall.sizes(end);
    Tbig     = onesPMTK([ns, sz]); 
    Tbig     = tabularFactorMultiply(Tbig, Tsmall); 
    obsModel = tabularCpdCreate(reshape(Tbig.T, [], sz)); 
    type     = 'discrete';
    
elseif isfield(emission, 'mu')
    
    smallMu    = emission.mu; 
    smallSigma = emission.Sigma; 
    d          = size(smallSigma, 1); 
    bigMu      = onesPMTK([d, ns]); 
    bigDom     = [1, (1:nHnodes)+1]; 
    smallDom   = [1, parents(intra, size(intra, 1))+1];
    bigMu      = bsxTable(@times, bigMu, smallMu, bigDom, smallDom); 
    bigMu      = reshape(bigMu, d, []); 
    bigSigma   = onesPMTK([d, d, ns]); 
    bigDom     = [1, 2, (1:nHnodes)+2]; 
    smallDom   = [1, 2, parents(intra, size(intra, 1))+2];
    bigSigma   = bsxTable(@times, bigSigma, smallSigma, bigDom, smallDom); 
    bigSigma   = reshape(bigSigma, d, d, []); 
    obsModel   = condGaussCpdCreate(bigMu, bigSigma);
    type       = 'gaussian';
    
else
   error('unrecognized emission type');  
end

hmm = hmmCreate(type, pi, A, obsModel); 
end


%{


intra = zeros(4);
intra(1, 4) = 1;
intra(2, 4) = 1;
intra(3, 4) = 1; 


inter = zeros(4); 
inter(1, 1) = 1; 
inter(2, 2) = 1; 
inter(3, 3) = 1; 

ns = [3 4 2];
slice1CPDs{1} = tabularCpdCreate(ones(ns(1), 1)); 
slice1CPDs{2} = tabularCpdCreate(ones(ns(2), 1)); 
slice1CPDs{3} = tabularCpdCreate(ones(ns(3), 1)); 

slice2CPDs{1} = tabularCpdCreate(ones(ns(1), ns(1)));
slice2CPDs{2} = tabularCpdCreate(ones(ns(2), ns(2))); 
slice2CPDs{3} = tabularCpdCreate(ones(ns(3), ns(3))); 

d = 5; 
emission.mu = onesPMTK([d, ns]);
emission.Sigma = onesPMTK([d d ns]); 
sdgm = dgmSeqCreate(intra, inter, slice1CPDs, slice2CPDs, emission)

hmm = dgmSeqToHmm(sdgm);

%}