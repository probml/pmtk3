function Xhat = efa_predict_m(Z,theta,params)

Amhat   =  exp(Z*theta.beta);
for m=1:max(params.mMap)
  ind = find(params.mMap==m);
  Xhat(:,ind) = bsxfun(@times,Amhat(:,ind),1./sum(Amhat(:,ind),2));
end
