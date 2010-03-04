function r = polya_sample(a,n)
% POLYA_SAMPLE      Sample from Dirichlet-multinomial (Polya) distribution.
% POLYA_SAMPLE(a,n) returns a matrix of histograms.
% If A is a row, the histograms are the rows, others they are the columns.
% N is a vector whose length is the number of histograms.
% N(i) will be the total count in histogram i.

row = (rows(a) == 1);

a = a(:);
p = dirichlet_sample(a,length(n));
r = zeros(size(p));
for i = 1:length(n)
  r(:,i) = sample_hist(p(:,i),n(i));
end
if row
  r = r';
end

end