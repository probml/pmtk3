function [d] = lbfgsC(g,s,y,Hdiag)
% alias for lbfgs for installations missing lbfgsC.mex32
    d = lbfgs(g, s, y, Hdiag);
end