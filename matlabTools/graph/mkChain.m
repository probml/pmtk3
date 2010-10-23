function G = mkChain(T)
% Make a 1D chain-structured graph of length T

% This file is from matlabtools.googlecode.com

G = diag(ones(T-1, 1), 1);
end
