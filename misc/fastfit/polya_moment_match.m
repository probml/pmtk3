function a = polya_moment_match(data)
% DATA is a matrix of count vectors (rows)

sdata = sum(data, 2);
p = data ./ repmat(sdata+eps,1,size(data, 2));
a = dirichlet_moment_match(p);

end