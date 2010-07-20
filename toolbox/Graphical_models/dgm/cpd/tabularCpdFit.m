function cpd = tabularCpdFit(cpd, data)
%% Fit a tabular CPD
% Each *row* of data is an observation of [parents, child]
cpd.T = mkStochastic(computeCounts(data, cpd.sizes) + cpd.prior); 
end

