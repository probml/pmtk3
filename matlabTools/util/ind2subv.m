function sub = ind2subv(siz,index)
% Return a subscript vector from a linear index
% IND2SUBV(SIZ,IND) returns a vector of the equivalent subscript values 
% corresponding to a single index into an array of size SIZ.
% If IND is a vector, then the result is a matrix, with subscript vectors
% as rows.
%
% See ind2subvBsxfunDemo for a timing comparison

% This file is from pmtk3.googlecode.com



n = length(siz);
cum_size = cumprod(siz(:)');
prev_cum_size = [1 cum_size(1:end-1)];
index = index(:) - 1;
%sub = rem(repmat(index,1,n),repmat(cum_size,length(index),1));
remainder = @(x,y)rem(x,y);
sub = bsxfun(remainder, index, cum_size);

%sub = floor(sub ./ repmat(prev_cum_size,length(index),1))+1;
sub = floor(sub ./ bsxfun(@times, prev_cum_size, ones(length(index),1))) + 1;


% slow way
%for dim = n:-1:1
%  sub(:,dim) = floor(index/cum_size(dim))+1;
%  index = rem(index,cum_size(dim));
%end



end
