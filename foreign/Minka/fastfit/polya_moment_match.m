function a = polya_moment_match(data)
% DATA is a matrix of count vectors (rows)

sdata = row_sum(data);
p = data ./ repmat(sdata+eps,1,cols(data));
a = dirichlet_moment_match(p);
