function X = chi2invPMTK(p, v)
% Replacement for the stats toolbox chi2inv function
% 
%%
if statsToolboxInstalled
    X = chi2inv(p, v);
else
    % Note, the gammincinv function was only introduced in Matlab version
    % 2009a. If you come up with a replacement function, please let us
    % know. 
    X = 2*gammaincinv(p, v/2);
end
end

