function [f,g] = dualSVMLoss(alpha,K,y)

nInstances = length(y);

f = -sum(alpha);
g = -ones(nInstances,1);
for i = 1:nInstances
    for j = 1:nInstances
        tmp = y(i)*y(j)*K(i,j);
        f = f + (1/2)*alpha(i)*alpha(j)*tmp;
        g(i) = g(i) + (1/2)*alpha(j)*tmp;
        g(j) = g(j) + (1/2)*alpha(i)*tmp;
    end
end
