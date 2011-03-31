function err = efa_compute_error_m(X,Xhat,R)

  err = mean(sum(X(R).*log(max(Xhat(R),eps))));
