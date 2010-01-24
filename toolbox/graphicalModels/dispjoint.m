function dispjoint(J, useLatex)
% Display the entries in a joint probability table

if nargin < 2
  sz = size(J);
  for i=1:prod(sz)
    ndx = ind2subv(sz, i);
    fprintf(1, '%d ', ndx);
    fprintf(1, ': ');
    fprintf(1, '%6.4f ', J(i));
    fprintf(1, '\n');
  end
else
  sz = size(J);
  for i=1:prod(sz)
    ndx = ind2subv(sz, i);
    fprintf(1, '%d & ', ndx-1);
    fprintf(1, '%6.4f ', J(i));
    fprintf(1, '\\\\\n');
  end
end

