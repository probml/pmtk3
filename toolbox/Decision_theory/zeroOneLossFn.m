
function L = zeroOneLoss(yhat, ytest)
L = (yhat(:) ~= ytest(:));
end
