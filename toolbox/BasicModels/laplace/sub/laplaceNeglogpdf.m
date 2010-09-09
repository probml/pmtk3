function out=laplaceNeglogpdf(w,scale)
% Laplace negative log pdf

% This file is from pmtk3.googlecode.com

gamma = sqrt(2*scale);
out=abs(w)*gamma;
end
