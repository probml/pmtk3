function X = chi2invPMTK(p, v)
% Replacement for the stats toolbox chi2inv function
X = 2*gammaincinv(p, v/2);
end

