function p = studentProb(x, mu, sigma2, dof)
%% Student probability
p = exp(studentLogprob(struct('mu',mu, 'Sigma', sigma2, 'dof', dof), x));
p = p(:)';

%p = (tpdf(( x-mu)./sqrt(sigma2), dof));
 
end

