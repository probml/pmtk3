function out=pen_normalexponentialgamma(z,shape,scale)
% gamma^2 = c = scale
lambda = shape;
gamma = sqrt(scale);
warning off
for k=1:length(z)
  out(k)=-z(k)^2/(4*gamma^2)...
      -log(paracyl(-2*(lambda+1/2),abs(z(k))/gamma));
end
warning on
end