function G = mkChain(len)
%% Make a chain dag of length len

G = diag(ones(len-1, 1), 1);
end