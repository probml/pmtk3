function out=laplaceNeglogpdfDeriv(w,scale)
% Derivative of the laplace logpdf function
% PMTKsimpleModel laplace
gamma = sqrt(2*scale);
out=gamma;
end