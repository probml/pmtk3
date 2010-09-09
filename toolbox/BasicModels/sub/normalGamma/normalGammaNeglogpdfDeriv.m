function out=normalGammaNeglogpdfDeriv(w,shape,scale)
% Derivative of the normal gamma negative logpdf function

% This file is from pmtk3.googlecode.com

lambda = shape;
gamma = sqrt(2*scale);
out=gamma*besselk(lambda-3/2,gamma*abs(w),1)./besselk(lambda-1/2,gamma*abs(w),1);
out = out(:);
out(isnan(out))=inf;
end
