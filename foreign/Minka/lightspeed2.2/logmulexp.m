function s = logmulexp(a,b)
%LOGMULEXP        Matrix multiply in the log domain.
% logmulexp(a,b) returns log(exp(a)*exp(b)) while avoiding numerical underflow.
% The * is matrix multiplication.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

s = repmat(a,cols(b),1) + kron(b',ones(rows(a),1));
s = reshape(logsumexp(s,2),rows(a),cols(b));

%s = kron(a',ones(1,cols(b))) + repmat(b,1,rows(a));
%s = reshape(logsumexp(s),cols(b),rows(a))';
