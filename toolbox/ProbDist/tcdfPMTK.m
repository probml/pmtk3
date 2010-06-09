function p = tcdfPMTK(X, dof)
% Replacement for the stats toolbox tcdf (Student's T CDF)

p = betainc(dof ./ (dof + X.^2), dof/2, 0.5, 'lower') / 2;
pos = X > 0; 
p(pos) = 1 - p(pos); 
p(X == 0) = 0.5; 

%assert(approxeq(p, tcdf(X, dof))); 
end