function [w] = projectSimplex(v)
% Computest the minimum L2-distance projection of vector v onto the probability simplex
nVars = length(v);
mu = sort(v,'descend');
sm = 0;
for j = 1:nVars
    sm = sm+mu(j);
   if mu(j) - (1/j)*(sm-1) > 0
       row = j;
       sm_row = sm;
   end
end
theta = (1/row)*(sm_row-1);
w = max(v-theta,0);