function test_sameobject
% Result should be 1 in both cases below.

a = rand(4);
b = a;
if sameobject(a,b) ~= 1
  error('failed');
end
if helper(a,a) ~= 1
  error('failed');
end
disp('Test passed.')

function x = helper(a,b)

x = sameobject(a,b);
