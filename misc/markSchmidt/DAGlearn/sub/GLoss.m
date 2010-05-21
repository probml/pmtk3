function [nll] = GLoss(XX,Xy,yy,w)
    nll = (1/2)*(w'*XX*w - 2*w'*Xy + yy);
end