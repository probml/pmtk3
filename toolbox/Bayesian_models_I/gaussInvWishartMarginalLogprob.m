function logp = gaussInvWishartMarginalLogprob(model, X)
% logp(i) = int_S log p(X(i, :) | model) 

mu    = model.mu;
Sigma = model.Sigma;
dof   = model.dof;
k     = model.k;
d     = size(Sigma, 1); 

student.dof   = dof - d + 1; 
student.mu    = mu; 
student.Sigma = Sigma.*(k+1)./(k*(dof-d+1));

logp = studentLogprob(student, X); 

end