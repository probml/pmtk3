function [f,g] = funObjPoissonFA(vec, y, params)
% gradient computation for learning parameters

  Dz = length(params.mean);
  [D, N] = size(y);

  % get beta
  B = reshape(vec(1:Dz*D),D,Dz);
  params.beta = B;

  % mean
  vec = vec(Dz*D+1:end);
  m = reshape(vec(1:Dz*N), Dz, N);
  params.mean = sum(m,2)/N;

  % compute f,g wrt m and V
  if nargout == 1
    [f] = funObjInferPoissonFA(vec, y, params);
  else
    [f,g,t,m,V] = funObjInferPoissonFA(vec, y, params);
  end

  % gradient
  if nargout>1
    t4 = zeros(Dz,D);
    %t5 = zeros(Dz,D);
    for d = 1:D
      temp = sum(bsxfun(@times, reshape(V,Dz^2,N), t(d,:)),2);
      t4(:,d) = -reshape(temp, Dz,Dz)*B(d,:)';
      %t5(:,d) = m*t(d,:)';
    end
    t4 = (t4 + m*y'-m*t')';
    g = [-t4(:)/N; g];
  end

