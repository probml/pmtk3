function [l,d,perm] = mcholC(A,mu)
% alias for mchol for installations missing mex files
    [l,d,perm] = mchol(A,mu);
end