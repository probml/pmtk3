function L = logmarglikDirichletMultinom(N, alpha)
% L(i) = marginal liklelihood of counts N(i,:) given Dirichlet prior alpha(i,:)
[q r] = size(N);
L = zeros(q,1);
for i=1:q % should vectorize this!
  L(i) = gammaln(sum(alpha(i,:))) - gammaln(sum(N(i,:)+alpha(i,:))) ...
    + sum(gammaln(N(i,:)+alpha(i,:))) - sum(gammaln(alpha(i,:)));
end
end
