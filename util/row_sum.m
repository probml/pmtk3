function s = row_sum(x)
% ROW_SUM   Sum for each row.
% A faster and more readable alternative to sum(x,2).

% unfortunately, this removes any sparseness of x.
s = x*ones(cols(x),1);

