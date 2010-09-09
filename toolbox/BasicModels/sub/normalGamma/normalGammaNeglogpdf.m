function out=normalGammaNeglogpdf(w,shape, scale)
% Nomral gamma negative logpdf

% This file is from pmtk3.googlecode.com

lambda = shape;
gamma = sqrt(2*scale);
%warning off
out=(0.5-lambda).*log(abs(w))-log(besselk(lambda-0.5,gamma*abs(w)));
out = out(:);
%warning on
end
