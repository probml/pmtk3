function [observed, hidden] = hmmDiscreteSample(model, len)
% hidden{i}(1:len(i)) ~ markov(model.pi, model.A)
% observed{i}(t) ~ discrete(model | hidden{i}(t))

ns = length(len);
hidden   = cell(ns, 1);
observed = cell(ns, 1);
E = model.E;
for i=1:ns
    T = len(i);
    hidden{i} = rowvec(markovSample(model, T, 1));
    observed{i} = zeros(1, T); 
    for t=1:T
        observed{i}(t) = sampleDiscrete(E(hidden{i}(t), :));
    end
end

end