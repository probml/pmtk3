function err = efa_compute_error_b(X,Xhat,R)

err = mean((X(R).*log(max(Xhat(R),eps)) + (1-X(R)).*log(max(1-Xhat(R),eps) )));

%err = mean((X(R)-Xhat(R)).^2 );

