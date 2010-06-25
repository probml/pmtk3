function B = hmmMkLocalEvidence(model, X)
% B(j, t) = p(X(t) | S(t) = j, model), where S(t) denotes the hidden state
% at time t. X is a single observation.
%
% *** X is a single observation ***
if iscell(X)
    X = X{1};
end
switch lower(model.type)
    case 'gauss'
        emission  = model.emission;
        nstates   = model.nstates;
        seqLength = size(X, 1);
        B = zeros(nstates, seqLength);
        for j=1:nstates
            B(j, :) = exp(gaussLogprob(emission{j}, X));
        end
    case 'discrete'
        % We can simply index directly into the emission probabilities
        B = model.emission(:, X);
    otherwise
        error('%s is an invalid type', model.type);
end
end