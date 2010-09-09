function X = betainvPMTK(p, a, b, tail)
% Inverse of the beta cdf
% Replacement for the stats toolbox betainv function
%%

% This file is from pmtk3.googlecode.com


upper = (nargin > 3) && strcmpi(tail, 'upper');
    
if statsToolboxInstalled || isOctave
    if upper
        X = betainv(1-p, a, b);
    else
        X = betainv(p, a, b);
    end
elseif ~(verLessThan('matlab', '7.8'))
    % Just call the matlab, (not stats) built in betaincinv without error
    % checking the parameters: betaincinv was released in 7.8
    if upper
        X = betaincinv(p, a, b, 'upper');
    else
        X = betaincinv(p, a, b);
    end
else
    if upper
        X = betainvOct(1-p, a, b);
    else
        X = betainvOct(p, a, b);
    end    
end
