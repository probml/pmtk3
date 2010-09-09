function S = invChi2Sample(arg1, arg2, arg3)
% Sample from an inverse Chi^2 distribution
% See Gelman p580
% S = invChi2Sample(model, n); OR S = invChi2Sample(dof, scale, n);
%%

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    dof   = model.dof;
    scale = model.scale;
    if nargin < 2,
        n = 1;
    else
        n = arg2;
    end
else
    dof   = arg1;
    scale = arg2;
    if nargin < 3
        n = 1;
    else
        n = arg3;
    end
    model = structure(dof, scale);
end


S = dof*scale./chi2Sample(model, n);
end
