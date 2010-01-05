function y = scale_cols(x, s)
% SCALE_COLS       Scale each column of a matrix.
% SCALE_COLS(x,s) returns matrix y, same size as x, such that
% y(:,i) = x(:,i)*s(i)
% It is more efficient than x*diag(s), but consumes a similar amount of memory.
% Warning: It consumes a lot of memory when x is sparse.

y = x.*repmat(s(:).', rows(x), 1);
%y = x.*(ones(rows(x),1)*s(:)');
