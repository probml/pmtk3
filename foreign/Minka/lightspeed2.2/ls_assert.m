function assert(condition,message)

if ~condition
  if nargin < 2
    error('Assertion failed');
  end
  error(message)
end
