function S = dirichletSample(arg1, arg2)
%% S(1:n, :) ~ dir(alpha)
% S = dirichletSample(alpha, n), OR S = dirichletSample(model, n)
%%

% This file is from pmtk3.googlecode.com



if isstruct(arg1)
    model = arg1;
    alpha = model.alpha;
else
    alpha = arg1;
end


if nargin < 2
    n = 1;
else
    n = arg2;
end
alpha = rowvec(alpha);
S = dirichlet_sample(alpha, n);

end
