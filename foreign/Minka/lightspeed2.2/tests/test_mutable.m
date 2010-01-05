x = mutable;
x(1) = 5;
y = x;
x(1) = 4;
assert(y(1) == 4);

x = mutable(struct);
y = x;
x.a = 4;
assert(y.a == 4);
fprintf('Test passed.\n');
