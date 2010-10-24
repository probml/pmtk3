function y = logdet(A)
% Compute log(det(A)) where A is positive-definite
% This is faster and more stable than using log(det(A)).
%
%PMTKauthor Tom Minka
% (c) Microsoft Corporation. All rights reserved.

% This file is from pmtk3.googlecode.com

try
    U = chol(A);
    y = 2*sum(log(diag(U)));
catch %#ok
    y = 0;
    warning('logdet:posdef', 'Matrix is not positive definite');
end

end
