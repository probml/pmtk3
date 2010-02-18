function out=normalExpGammaNeglogpdf(z,shape,scale)
% gamma^2 = c = scale
lambda = shape;
gamma = sqrt(scale);
out = zeros(1, length(z));
for k=1:length(z)
  out(k)=-z(k)^2/(4*gamma^2)...
      -log(paracylFast(-2*(lambda+1/2),abs(z(k))/gamma));
end
end