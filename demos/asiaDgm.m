% Asia example from  
%http://sujitpal.blogspot.com/2013/07/bayesian-network-inference-with-r-and.html

% This file is from pmtk3.googlecode.com

nodeNames = {'A','S','T','L','E','B','X','D'};
N = length(nodeNames);
G = zeros(N,N);
nodeNums = cell(1,N);
for i=1:N
    nodeNums{nodeNames{i}} = i;
end
G(nodeNums{'A'}, nodeNums{'T'}) = 1;
G(nodeNums{'S'}, nodeNums{'L'}) = 1;
G(nodeNums{'S'}, nodeNums{'B'}) = 1;
G(nodeNums{'T'}, nodeNums{'E'}) = 1;
G(nodeNums{'L'}, nodeNums{'E'}) = 1;
G(nodeNums{'B'}, nodeNums{'D'}) = 1;
G(nodeNums{'E'}, nodeNums{'X'}) = 1;
G(nodeNums{'E'}, nodeNums{'D'}) = 1;

myTrue = 1; myFalse = 2; % true, false
CPTs = cell(1,N);
CPTs{nodeNums{'A'}} = [0.01 0.99];
CPTs{nodeNums{'S'}} = [0.5 0.5];

tmp = zeros(2,2); % tmp(A, T)
tmp(myTrue, :) = [0.05 1-0.05];
tmp(myFalse, :) = [0.01 1-0.01];
CPTs{nodeNums{'T'}} = tmp;

tmp = zeros(2,2); % tmp(S, L)
tmp(myTrue, :) = [0.1 1-0.1];
tmp(myFalse, :) = [0.01 1-0.01];
CPTs{nodeNums{'L'}} = tmp;

tmp = zeros(2,2); % tmp(S, B)
tmp(myTrue, :) = [0.6 1-0.6];
tmp(myFalse,:) = [0.3 1-0.3];
CPTs{nodeNums{'B'}} = tmp;

tmp = zeros(2,2,2); % tmp(T, L, E)
tmp(myTrue, myTrue, :) = [1 0];
tmp(myTrue, myFalse, :) = [1 0];
tmp(myFalse, myTrue, :) = [1 0];
tmp(myFalse, myFalse, :) = [0 1];
CPTs{nodeNums{'E'}} = tmp;

tmp = zeros(2,2); % tmp(E, X)
tmp(myTrue, :) = [0.98 1-0.98];
tmp(myFalse,:) = [0.05 1-0.05];
CPTs{nodeNums{'X'}} = tmp;

% pmtk requires that parents occur in topological order
tmp = zeros(2,2,2); % tmp(E, B, D)
tmp(myTrue, myTrue, :) = [0.9 0.1];
tmp(myTrue, myFalse, :) = [0.7 0.3];
tmp(myFalse, myTrue, :) = [0.8 0.2];
tmp(myFalse, myFalse, :) = [0.1 0.9];
CPTs{nodeNums{'D'}} = tmp;

dgm = dgmCreate(G, CPTs); 

%{
Sanity check.
 p(A=t|T=t) = p(A=t) p(T=t|A=t) / [
    p(A=t) p(T=t|A=t)  + p(A=f) p(T=t|A=f)]
= 0.01 * 0.05 / (0.01 * 0.05 + 0.99 * 0.01)
= 0.0481
 %}
ev = zeros(1,N);
ev(nodeNums{'T'}) = myTrue;
belNodes = dgmInferNodes(dgm, 'clamped', ev);
prob = belNodes{nodeNums{'A'}}.T(myTrue);
assert(approxeq(prob, 0.0481))

%{
Sanity check.
 p(S=t|L=t) = p(S=t) p(L=t|S=t) / [
    p(S=t) p(L=t|S=t)  + p(S=f) p(L=t|S=f)]
= 0.5 * 0.1 / (0.5 * 0.1  + 0.5 * 0.01)
 = 0.9091
 %}
ev = zeros(1,N);
ev(nodeNums{'L'}) = myTrue;
belNodes = dgmInferNodes(dgm, 'clamped', ev);
prob = belNodes{nodeNums{'S'}}.T(myTrue);
assert(approxeq(prob, 0.9091))


% X=t, p(L=t) = 0.4887
ev = zeros(1,N);
ev(nodeNums{'X'}) = myTrue;
belNodes = dgmInferNodes(dgm, 'clamped', ev);
prob = belNodes{nodeNums{'L'}}.T(myTrue)

% X=t, T=t, p(L=t) = 0.055 - explaining away
ev = zeros(1,N);
ev(nodeNums{'X'}) = myTrue;
ev(nodeNums{'T'}) = myTrue;
belNodes = dgmInferNodes(dgm, 'clamped', ev);
prob = belNodes{nodeNums{'L'}}.T(myTrue)



% p(D=t) = 0.4360 - prediction
ev = zeros(1,N);
belNodes = dgmInferNodes(dgm, 'clamped', ev);
prob = belNodes{nodeNums{'D'}}.T(myTrue)

% S=t, p(D=t) = 0.5528  - prediction
ev = zeros(1,N);
ev(nodeNums{'S'}) = myTrue;
belNodes = dgmInferNodes(dgm, 'clamped', ev);
prob = belNodes{nodeNums{'D'}}.T(myTrue)



