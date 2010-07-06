function dgm = hmm2Dgm(model, X)
%% Given a single observation sequence, convert an HMM to a DGM
% Each CPD in the DGM stores its own local evidence node to handle the
% continuous observation. 
% X is T-by-d
%% 
B        = hmmMkLocalEvidence(model, X); 
T        = size(X, 1); 
CPD      = cell(T, 1); 
CPD{1}   = tabularCpdCreate(model.pi, 'localev', normalize(B(:, 1))); 
A        = model.A; 
for t=2:T
   CPD{t} = tabularCpdCreate(A, 'localev', normalize(B(:, t))); 
end
G = zeros(T, T); 
for t=1:T-1
    G(t, t+1) = 1; 
end

dgm = dgmCreate(G, CPD); 

end