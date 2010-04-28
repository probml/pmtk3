function [f,g] = fnjoin(w, obj, grad)
f = obj(w);
g = grad(w);
end