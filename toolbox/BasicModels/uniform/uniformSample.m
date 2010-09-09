function S = uniformSample(arg1, arg2, arg3)
% Sample n uniformly distributed random numbers in the range [a, b].
% (Note, n can also be a size vector as in sampleUniform(model, [3,2]),
% yielding a 3x2 matrix of numbers.
% S = sampleUniform(model, n); OR S = sampleUniform(a, b, n); 

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1; 
    a     = model.a; 
    b     = model.b;
    if nargin < 2
        n = 1;
    else
        n = arg2; 
    end
else
   a = arg1; 
   b = arg2; 
   if nargin < 3
       n = 1;
   else
       n = arg3; 
   end
end


if isscalar(n)
    n = [n, 1]; 
end
S = a + rand(n)*(b-a);

end
