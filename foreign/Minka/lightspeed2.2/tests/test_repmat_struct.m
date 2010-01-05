% thanks to Marek Petrik for finding this bug
a.state = 1;
a.action = 0;
x = repmat(a, 1, 10);
if length(fieldnames(x)) ~= 2
  error('repmat struct failed')
end
