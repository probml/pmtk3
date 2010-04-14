function fnJoinDemo()
%% Squared Error Fn Demo
nInst = 1000;
nVars = 100;
A = randn(nInst,nVars);
x = rand(nVars,1).*(rand(nVars,1) > .5);
b = A*x + randn;

funObj = @(x)SquaredError(x,A,b);

obj = @(w) sum((A*w-b).^2);
grad = @(w) 2*(A.'*(A*w-b));
funObj2 = @(w) fnJoin(w, obj, grad);

[f1,g1]= funObj(x);
[f2,g2] = funObj2(x);
assert(approxeq(f1,f2))
assert(approxeq(g1,g2))
end

function [f,g] = SquaredError(w,X,y)
% w(feature,1)
% X(instance,feature)
% y(instance,1
Xw = X*w;
res = Xw-y;
f = sum(res.^2);
g = 2*(X.'*res);
end