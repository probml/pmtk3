function p = betacdfPMTK(X, a, b)
%% Replacement for the stats toolbox betacdf function
% Just calls the built-in matab betainc function

p = betainc(X, a, b);


end