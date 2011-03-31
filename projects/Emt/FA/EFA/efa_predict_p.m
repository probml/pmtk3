function Xhat = efa_predict_p(Z,theta,params)

Xhat   =  exp(Z*theta.beta);