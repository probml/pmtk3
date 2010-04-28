function B = hmmDiscreteMkLocalEvidence(model, X) 

X = colvec(X); 
emission  = model.emission;
nstates   = model.nstates;
seqLength = length(X);
B = zeros(nstates, seqLength);
for j=1:nstates
    B(j, :) = exp(discreteLogprob(emission{j}, X));
end

end