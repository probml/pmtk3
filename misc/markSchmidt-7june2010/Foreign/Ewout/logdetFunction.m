function [f,g] = logdetFunction(w,sigma)

n = size(sigma,1);
w = reshape(w,[n,n]);

f = -logdet(sigma + w,-Inf);
if ~isinf(f)
   g = -inv(sigma + w);
else
   g = zeros(size(sigma));
end

g = g(:);

global trace

if trace == 1
   global fValues
   fValues(end+1,1) = -f;
   drawnow
end

end

function l = logdet(M,errorDet)

[R,p] = chol(M);
if p ~= 0
   l = errorDet;
else
   l = 2*sum(log(diag(R)));
end

end