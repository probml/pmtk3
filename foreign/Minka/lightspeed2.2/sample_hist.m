function h = sample_hist(p, n)
%SAMPLE_HIST     Sample from a multinomial distribution.
% SAMPLE_HIST(P,N) returns a random matrix of counts, same size as P, 
% whose column sums are all N.  Column j is sampled from a multinomial with
% the probabilities p(:,j).
%
% Example:
%   sample_hist([0.2 0.4; 0.8 0.6],100)

% The advantage of this alg is that the running time grows slowly with n.
% It is the same alg used by BUGS.
% If n is very small then it is faster to just take n samples from p.

if nargin < 2
  n = 1;
end

h = zeros(size(p));
z = repmat(1,1,cols(p));
n = repmat(n,1,cols(p));
js = 1:cols(p);
% loop bins
for i = 1:(rows(p)-1)
  % the count in bin i is a binomial distribution
  for j = js
    h(i,j) = randbinom(p(i,j)/z(j), n(j));
  end
  n = n - h(i,:);
  z(js) = z(js) - p(i,js);
  js = find(z > 0);
end
h(end,:) = n;
