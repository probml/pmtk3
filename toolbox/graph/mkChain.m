function G = mkChain(T)
% Make a 1D chain-structured graph of length T
G = diag(ones(T-1, 1), 1);
end
