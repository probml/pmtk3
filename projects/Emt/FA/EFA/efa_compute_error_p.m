function err = efa_compute_error_p(X,Xhat,R)

err =  mean((X(R)-Xhat(R)).^2);