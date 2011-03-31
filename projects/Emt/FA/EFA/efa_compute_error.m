function err=efa_compute_error(X, Xhat, R);

%Compute error given ground truth and predictions
%for each distribution 
dists = sort(fields(X));
err.all = 0;
for d = 1:length(dists)
  error_func = str2func(sprintf('efa_compute_error_%s',dists{d}));
  err.(dists{d}) = error_func(X.(dists{d}),Xhat.(dists{d}),R.(dists{d}));
  err.all = err.all + err.(dists{d});
end

end