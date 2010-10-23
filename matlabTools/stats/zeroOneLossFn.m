
% This file is from matlabtools.googlecode.com


function L = zeroOneLoss(yhat, ytest)
L = (yhat(:) ~= ytest(:));
end
