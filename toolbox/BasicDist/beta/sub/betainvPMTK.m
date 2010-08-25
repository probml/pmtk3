function X = betainvPMTK(p, a, b)
% Inverse of the beta cdf
% Direct replacement for the stats toolbox betainv function

% Just call the matlab, (not stats) built in betaincinv without error
% checking the parameters. 

X = betaincinv(p, a, b);



end