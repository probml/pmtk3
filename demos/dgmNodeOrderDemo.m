


% When queries are not in topogical order
% problems may arise...

% This file is from pmtk3.googlecode.com

setSeed(0);

G = zeros(2,2);
%C = 1; S = 2;
C = 2; S = 1;
G(C, S) = 1;
nstates = [2 2];
CPDs = mkRndTabularCpds(G, nstates);  
dgm =  dgmCreate(G, CPDs, 'infEngine', 'jtree'); 

 
clear fac
fac{C} = tabularFactorCreate(CPDs{C}.T, [C]);
fac{S} = tabularFactorCreate(CPDs{S}.T, [C S]);
jointF = tabularFactorMultiply(fac);
%jointF = tabularFactorMultiplyDomain(fac, [C S]); % specify domain of joint

query = [C,S];
pquery1 = dgmInferQuery(dgm, query); 
pquery2 = tabularFactorMarginalize(jointF, query);

joint = repmat(CPDs{C}.T(:), 1, 2) .* CPDs{S}.T;

assert(approxeq(pquery1.T, joint))
assert(tfequal(pquery1, pquery2)) 



%%

% Make DAG
%    C 2
%   / \
%  v  v
% 4 S  R 3
%   \/
%   v
%   W 1
%
% interally this becomes
%    1
%   / \
%  v  v
% 3   2
%   \/
%   v
%   4
% So when the user asks for the marginal on node W,
% we compute the marginal on node 4, then rename it to W/1.
%
% Also, if we give it data X(:,[W C R S])
% we permtue it internally to XX(:, [2 3 4 1])

nvars = 4; 
%Create the dgm
[dgmJ, C, S, R, W] = mkSprinklerDgmOutOfOrder('infEngine', 'jtree'); 
dgmV = mkSprinklerDgmOutOfOrder('infEngine', 'varelim'); 
dgmE = mkSprinklerDgmOutOfOrder('infEngine', 'enum'); 

fac = {};
fac{C} = tabularFactorCreate(reshape([0.5 0.5], 2, 1), [C]);
fac{S} = tabularFactorCreate(reshape([0.5 0.9 0.5 0.1], 2, 2), [C S]);
fac{R} = tabularFactorCreate(reshape([0.8 0.2 0.2 0.8], 2, 2), [C R]);
fac{W} = tabularFactorCreate(reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], 2, 2, 2), [S R W]);
jointF = tabularFactorMultiply(fac);

% Inference
FALSE = 1; TRUE  = 2;

[pWj, logZ, qq] = dgmInferQuery(dgmJ, W);
pWv = dgmInferQuery(dgmV, W);
pWe = dgmInferQuery(dgmE, W);
assert(tfequal(pWj, pWv, pWe))
assert(approxeq(pWj.T(TRUE), 0.6471, 1e-4)) 

pSWj = dgmInferQuery(dgmJ, [S, W]); 
pSWv = dgmInferQuery(dgmV, [S, W]);
pSWe = dgmInferQuery(dgmE, [S, W]);
 assert(approxeq(pSWj.T(TRUE, TRUE), 0.2781, 1e-4)); 
assert(tfequal(pSWj, pSWv, pSWe));

% When queries are not in topogical order
% problems may arise...
query = [W,R,C];
pSWj = dgmInferQuery(dgmJ, query); 
pSWv = dgmInferQuery(dgmV, query);
pSWe = dgmInferQuery(dgmE, query);
pquery = tabularFactorMarginalize(jointF, query);

assert(tfequal(pSWj, pSWv, pSWe)); 

