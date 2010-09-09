function err = compareFactors(facs1, facs2)
%% compare two sets of factors
% err(i) is the rmse between facs1{1} and facs2{2}
%%

% This file is from pmtk3.googlecode.com

nfacs = numel(facs1); 
err = zeros(nfacs, 1); 
for i=1:nfacs
   T1 = facs1{i}.T;
   T2 = facs2{i}.T;
   err(i) = sqrt(mean((T1(:) - T2(:)).^2));
end
end
