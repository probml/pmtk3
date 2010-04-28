function out=diffpen_normalexponentialgamma(z,shape,scale)
% gamma^2 = c = scale
lambda = shape;
gamma = sqrt(scale);
warning off
out=(lambda+0.5)/gamma...
      .*paracyl(-2*(lambda+1),abs(z)/gamma)...
      ./paracyl(-2*(lambda+1/2),abs(z)/gamma);
out = reshape(out, size(z));

if 0
out2 = zeros(size(z));
for k=1:length(z)
  out2(k)=(lambda+0.5)/gamma...
      *mpbdv(-2*(lambda+1),abs(z(k))/gamma)...
      /mpbdv(-2*(lambda+1/2),abs(z(k))/gamma);
end
assert(approxeq(out(:), out2(:)))
end

warning on
end