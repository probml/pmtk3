function Xhat = efa_predict_b(Z,theta,params)
  Xhat   =  logistic(Z*theta.beta);
end

function y = logistic(x)
  y = 1./(1+exp(-x));
end