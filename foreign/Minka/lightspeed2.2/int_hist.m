function h = int_hist(x, n)
% INT_HIST(x, n) is a histogram of all integer values 1..n in x.
% If n is not given, max(x) is used.

% Hans Olsson's one-liner from matlab faq
h = full(sum(sparse(1:length(x(:)),x(:),1)));
if nargin == 2
  if n > length(h)
    % pad with zeros
    h = [h zeros(1,n-length(h))];
  end
end
