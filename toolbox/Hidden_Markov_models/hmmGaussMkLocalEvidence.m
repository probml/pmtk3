function B = hmmGaussMkLocalEvidence(model, X) 

emission  = model.emission;
nstates   = model.nstates;
seqLength = size(X, 1);
B = zeros(nstates, seqLength);
for j=1:nstates
    B(j, :) = exp(gaussLogprob(emission{j}, X));
end

end