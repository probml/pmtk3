function [r1,r2] = quad_roots(a1, a2, a3)

t1 = -a2/2./a1;
t2 = sqrt(a2.^2 - 4*a1.*a3)/2./a1;
r1 = t1 + t2;
r2 = t1 - t2;
