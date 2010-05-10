function p = probit(x)
%% Probit function
if statsToolboxInstalled
    p = normcdf(x); % more accurate
else
    % See Bishop eq. 4.116
    p = 0.5*(1+erf(x)./sqrt(2));
end
end