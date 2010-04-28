function a = dirichlet_fit_s_simple(data,a)
% DIRICHLET_FIT_S_SIMPLE   Initial guess for Dirichlet precision.
% 
% DIRICHLET_FIT_S_SIMPLE(data,a) returns an initial guess for the Dirichlet
% parameter vector A, by scaling the input A.

bar_p = mean(log(data));
m = a/sum(a);
bar_p = sum(m.*bar_p);
s = 1/(sum(m.*log(m)) - bar_p);
s = s*(length(m)-1)/2;
a = s*m;

end