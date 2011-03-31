function err = efa_compute_error_c(X,Xhat,R)

err =  mean((X(R)-Xhat(R)).^2);