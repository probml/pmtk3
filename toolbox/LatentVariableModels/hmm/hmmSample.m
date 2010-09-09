function [observed, hidden] = hmmSample(model, len, nsamples)
% hidden{i}(1:len(i)) ~ markov(model.pi, model.A)
% observed{i}(t) ~ discrete(model.emission(hidden{i}(t), :))
%                 or
% observed{i}(1:d, t) ~ gauss(model.emission{hidden{i}(t)}))

% This file is from pmtk3.googlecode.com

SetDefaultValue(3, 'nsamples', 1);
if numel(len) == 1
    len = repmat(len, nsamples, 1);
end
hidden   = cell(nsamples, 1);
observed = cell(nsamples, 1);
switch lower(model.type)
    case 'discrete'
        
        E = model.emission.T;
        assert(size(E, 3) == 1); % not yet implemetned for the vector valued case
        for i=1:nsamples
            T = len(i);
            hidden{i}   = rowvec(markovSample(model, T, 1));
            observed{i} = zeros(1, T);
            for t=1:T
                observed{i}(t) = sampleDiscrete(E(hidden{i}(t), :));
            end
        end
    case 'gauss'
        d     = model.d;
        E     = model.emission;
        mu    = E.mu; 
        Sigma = E.Sigma; 
        for i=1:nsamples
            T = len(i);
            hidden{i}   = rowvec(markovSample(model, T, 1));
            observed{i} = zeros(d, T);
            for t=1:T
                k = hidden{i}(t); 
                observed{i}(:, t) = colvec(gaussSample(mu(:, k), Sigma(:, :, k), 1));
            end
        end
        
    case {'mixgausstied', 'student'}
        error('not yet implemented'); 
    otherwise
        error('%s is not a valid hmm type', model.type);
end
if nsamples == 1
    hidden = hidden{1};
    observed = observed{1};
end
