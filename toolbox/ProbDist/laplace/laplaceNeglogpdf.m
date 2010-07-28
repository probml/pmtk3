function out=laplaceNeglogpdf(w,scale)
% Laplace negative log pdf
% PMTKsimpleModel laplace
gamma = sqrt(2*scale);
out=abs(w)*gamma;
end
