function [beta,bias, svi] = svmRegrFit(K,y,e,C)
% Support vector regression
% One norm epsilon insensitive loss funciton

% Based on code by Steve Gunn
% http://www.isis.ecs.soton.ac.uk/resources/svminfo/

n = length(y);
H = [K -K; -K K];
f = [(e*ones(n,1) - y); (e*ones(n,1) + y)];
A = []; b = [];
Aeq = [ones(1,n) -ones(1,n)];
beq = 0;   
lb = zeros(2*n,1);    
ub = C*ones(2*n,1);   

alpha = quadprog(H,f,A,b,Aeq,beq,lb,ub);
beta =  alpha(1:n) - alpha(n+1:2*n);

epsilon = C*1e-6;
svi = find( abs(beta) > epsilon ); % support vectors

% find bias from average of support vectors with interpolation error e
% SVs with interpolation error e have alphas: 0 < alpha < C
svii = find( abs(beta) > epsilon & abs(beta) < (C - epsilon));
if length(svii) > 0
   bias = (1/length(svii))*sum(y(svii) - e*sign(beta(svii)) - K(svii,svi)*beta(svi));
else
   fprintf('No support vectors with interpolation error e - cannot compute bias.\n');
   bias = (max(y)+min(y))/2;
end
