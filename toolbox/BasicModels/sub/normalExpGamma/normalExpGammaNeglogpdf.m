function out = normalExpGammaNeglogpdf(z, shape, scale)
% Normal exponential gamma negative logpdf
% gamma^2 = c = scale

% This file is from pmtk3.googlecode.com

[nrows, ncols] = size(z);
z = colvec(z);
lambda = colvec(shape);
gamma = colvec(sqrt(scale));
out = -z.^2/(4*gamma^2)-colvec(log(paracyl(-2*(lambda+1/2), abs(z)./gamma)));
if isscalar(shape) && isscalar(scale)
    out = reshape(out, [nrows, ncols]);
end


if 0
    out2 = zeros(1, length(z));
    for k=1:length(z)
      out2(k)=-z(k)^2/(4*gamma^2)-log(mpbdv(-2*(lambda+1/2),abs(z(k))/gamma));
    end
    assert(approxeq(out, out2));
end




end
