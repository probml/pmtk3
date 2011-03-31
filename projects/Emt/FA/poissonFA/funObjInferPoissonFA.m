function [f,g,t,m,V] = funObjInferPoissonFA(vec, y, params)
% gradient computation for posterior distribution

  Dz = length(params.mean);
  [D, N] = size(y);

  % get m and V
  %mV = reshape(vec, Dz + Dz*(Dz+1)/2, N);
  %m = mV(1:Dz,:);
  m = reshape(vec(1:Dz*N), Dz, N);
  l = reshape(vec(Dz*N+1:end), Dz*(Dz+1)/2, N);
  L = zeros(Dz, Dz, N);
  idx = find(repmat(tril(ones(Dz)), [1 1 N]));
  L(idx) = l;
  B = params.beta;

  % objfun
  idx = find(tril(ones(Dz)));
  Bm = B*m;
  diff = bsxfun(@minus, params.mean, m);
  for n = 1:N
    V(:,:,n) = L(:,:,n)*L(:,:,n)';
    Vbeta(:,:,n) = V(:,:,n)*B';
    BVB(:,n) = diag(B*Vbeta(:,:,n));
    tracePrecMatV(n) = trace(params.precMat*V(:,:,n));
    logdet2piV(n) = logdet(2*pi*V(:,:,n));
    temp = tril(inv(L(:,:,n))' - params.precMat*L(:,:,n)); 
    invV(:,n) = temp(idx);
    for d = 1:D
      temp = tril(B(d,:)'*B(d,:)*L(:,:,n));
      BB(:,n,d) = temp(idx);
    end
  end
  yBm = y.*Bm;
  t = exp(Bm + 0.5*BVB);
  f = sum(sum(-log(factorial(y)) + yBm - t))...
      - 0.5*N*logdet(2*pi*params.covMat) - 0.5*sum(sum(diff.*(params.precMat*diff)))...
      - 0.5*sum(tracePrecMatV) + 0.5*sum(logdet2piV); 
  f = -f/N;

  % gradient
  if nargout > 1
    t1 = zeros(Dz,N);
    t2 = zeros(Dz,N);
    t3 = zeros(Dz*(Dz+1)/2,N);
    for d = 1:D
      t1 = t1 + bsxfun(@times, B(d,:)', y(d,:));
      t2 = t2 + bsxfun(@times, B(d,:)', t(d,:));
      %BB = B(d,:)'*B(d,:);
      t3 = t3 + bsxfun(@times, t(d,:), BB(:,:,d));
    end
    gV = -t3 + invV;
    gm = t1 - t2 + params.precMat*diff;
    g = [gm(:); gV(:)];
    g = -g/N;
  end



