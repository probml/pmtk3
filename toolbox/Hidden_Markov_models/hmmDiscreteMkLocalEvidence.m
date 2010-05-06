function B = hmmDiscreteMkLocalEvidence(model, X) 
% B(j, t) = p(X(t) | S(t) = j, model.E), where S(t) denotes the hidden state
% at time t. X is a single observation. 
%
%%

X = colvec(X); 
emission  = model.E;
nstates   = model.nstates;
seqLength = length(X);
B = zeros(nstates, seqLength);
m.d = 1;
m.K = size(model.E, 2);
for j=1:nstates
    m.T = emission(j, :)'; 
    B(j, :) = exp(discreteLogprob(m, X));
end

end