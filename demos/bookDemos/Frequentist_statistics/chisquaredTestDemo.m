% Demo of pearson's chi squared test

% This file is from pmtk3.googlecode.com


% Data from
% http://homepage.mac.com/samchops/B733177502/C1517039664/E20060507073109/index.html
%Y=[ 21 16 145 2 6 ; 14 4 175 13 4];

% Data from 
% http://en.wikipedia.org/wiki/Contingency_table
% pval = 0.1825 - retain the null at 5% level
O = [9 43; 4 44];
N=sum(sum(O));
nidot=sum(O,2);
ndotj=sum(O,1);
pdotj = ndotj/N; 
pidot = nidot/N;
E=N*pidot*pdotj;
chi2 =sum(sum(((O-E).^2)./E))

[J K] = size(O);
dof = (J-1)*(K-1);
pval = 1-chi2cdf(chi2, dof)


