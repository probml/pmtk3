function W = conservationWeights(S, ssCorr)
% Compute nucleotide sequence conservation weights
% This function computes the same values as the bioinformatics seqlogo
% function, i.e. 
%
% W = conservationWeights(S);
% C = seqlog(S);
% assert(approxeq(W, C{2}));
% 
% * Only handles nucleotides, i.e. ACTG, not amino acids, unlike seqlogo *
%% Input
%
% S        - an nsequences-by-npositions character array of with chars 
%            A,C,T,G, or a predifined profile matrix of the same size. 
%
% ssCorr   - if true, (default), the small sample size correction is
%            applied. This setting is ignored, (turned off) if S is a 
%            numeric matrix. 
% 
%            (see the bioinformatics seqlogo function for details)
%% Output 
%
% W is an nsequenes-by-npositions conservation weight matrix
%%
K = 4; % ACTG
if isnumeric(S)
    ssCorr = false;
    W = S./max(sum(S));
else
    if nargin < 2, ssCorr = true; end
    S = upper(S);
    [ns, np] = size(S);
    U = unique(S);
    m = length(U);
    W = zeros(m, np); 
    for j=1:m
       W(j, :) = sum(S == U(j));
    end
    W = W/ns;
end
F = W;
F(F == 0) = 1;
Sb = log2(K); 
Sf = -sum(log2(F).*F, 1);
if ssCorr
    E = (K-1)/(2*log(2)*ns);  % small sample correction
else
    E = 0;
end
R = Sb - Sf - E; 
W = bsxfun(@times, W, R); 
end