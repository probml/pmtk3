function out=diffpen_normalexponentialgamma(z,shape,scale)
% gamma^2 = c = scale
lambda = shape;
gamma = sqrt(scale);
warning off
for k=1:length(z)
  out(k)=(lambda+0.5)/gamma...
      *paracyl(-2*(lambda+1),abs(z(k))/gamma)...
      /paracyl(-2*(lambda+1/2),abs(z(k))/gamma);
end
warning on
end