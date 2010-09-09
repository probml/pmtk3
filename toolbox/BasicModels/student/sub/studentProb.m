function p = studentProb(x, mu, sigma2, dof)
%% Student probability

% This file is from pmtk3.googlecode.com

p = exp(studentLogprob(struct('mu',mu, 'Sigma', sigma2, 'dof', dof), x));
p = p(:)';

%p = (tpdf(( x-mu)./sqrt(sigma2), dof));
 
end

