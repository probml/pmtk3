function S = sampleUniform(model, n)
% Like the stats unifrnd function. Just samples n uniformly distributed
% random numbers in the range [model.a, model.b]. (Note, n can also
% be a size vector as in sampleUniform(model, [3,2]), yielding a 3x2 matrix
% of numbers. 

    if nargin < 2, n = 1; end
    if isscalar(n), n = [n, 1]; end 
    a = model.a; b = model.b; 
    S = a + rand(n)*(b-a);
   
end