function N = efa_get_N(X)
  f = fields(X);
  N=0;
  for i=1:length(f)
    N = max(N,size(X.(f{i}),1));   
  end
end