function out=normalGammaNeglogpdf(w,shape, scale)
% Nomral gamma negative logpdf
% PMTKsimpleModel normalGamma
lambda = shape;
gamma = sqrt(2*scale);
%warning off
out=(0.5-lambda).*log(abs(w))-log(besselk(lambda-0.5,gamma*abs(w)));
out = out(:);
%warning on
end