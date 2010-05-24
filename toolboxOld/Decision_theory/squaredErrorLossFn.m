function L = squaredErrorLoss(yhat, ytest)
L = (yhat(:) - ytest(:)).^2;
end