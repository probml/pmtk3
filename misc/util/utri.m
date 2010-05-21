function ndx = utri(d)
% Return the indices of the upper triangluar part of a square d-by-d matrix
% Does not include the main diagonal.
ndx = ones(d*(d-1)/2,1);
ndx(1+cumsum(0:d-2)) = d+1:-1:3;
ndx = cumsum(ndx);

end