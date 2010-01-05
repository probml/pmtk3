function s = logsumexp(a, dim, method)
% Returns log(sum(exp(a),dim)) while avoiding numerical underflow.
% Default is dim = 1 (columns).
% logsumexp(a, 2) will sum across rows instead of columns.
% Unlike matlab's "sum", it will not switch the summing direction
% if you provide a row vector.
%
% Example: s = logsumexp(rand(10,3),2)

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

if nargin < 2, dim = 2; end
if nargin < 3, method = 1; end

% subtract the largest in each column
y = max(a,[],dim);
if method==1
  dims = ones(1,ndims(a));
  dims(dim) = size(a,dim);
  a = a - repmat(y, dims);
else
  % Added by KPM. Just a hair faster (see timing comparison below).
  % A=rand(1000,100);N=100;
  % tic; for i=1:N, s1 = logsumexp(A,2,1); end; t1=toc;
  % tic; for i=1:N, s2=logsumexp(A,2,2); end; t2=toc;
  % assert(approxeq(s1,s2)); [t1 t2]
  a = bsxfun(@minus, a, y);
end

s = y + log(sum(exp(a),dim));
i = find(~isfinite(y));
if ~isempty(i)
  s(i) = y(i);
end
