function logp = gaussInvWishartLogprobBayes(arg1, arg2, arg3, arg4, arg5)
% logp(i) = int_S log p(X(i, :) | model)
% logp = gaussInvWishartLogprobBayes(model, X) OR
% logp = gaussInvWishartLogprobBayes(mu, Sigma, dof, k, X)
%%

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    X = arg2;
    mu    = model.mu;
    Sigma = model.Sigma;
    dof   = model.dof;
    k     = model.k;
else
    mu    = arg1;
    Sigma = arg2;
    dof   = arg3;
    k     = arg4;
    X     = arg5;
end

d     = size(Sigma, 1);

student.dof   = dof - d + 1;
student.mu    = mu;
student.Sigma = Sigma.*(k+1)./(k*(dof-d+1));

logp = studentLogprob(student, X);

end
