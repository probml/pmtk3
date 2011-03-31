function R = efa_not_observed(data);
  [X,params] = efa_prepare_data(data, params);
  R.m = ~isnan(X.m);
  R.b = ~isnan(X.b);
  R.c = ~isnan(X.c);
end
