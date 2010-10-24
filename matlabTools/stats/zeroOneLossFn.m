
% This file is from pmtk3.googlecode.com


function L = zeroOneLoss(yhat, ytest)
L = (yhat(:) ~= ytest(:));
end
