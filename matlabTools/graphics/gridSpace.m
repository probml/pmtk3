function g = gridSpace(varargin)
% Similar to built in ndgrid except the output g is a single matrix, regardless 
% of the number of inputs. Suppose [a,b,c] = ndgrid(1:10,1:10,1:10), if 
% g = gridSpace(1:10,1:10,1:10), then g = [a(:),b(:),c(:)];
%

% This file is from pmtk3.googlecode.com


    
if nargin==1, varargin = repmat(varargin,[1 2]); end
nout = numel(varargin);
for i=length(varargin):-1:1,
  siz(i) = numel(varargin{i});
end

g = zeros(prod(siz),nout);
for i=1:nout,
  x = varargin{i}(:); % Extract and reshape as a vector.
  s = siz; s(i) = []; % Remove i-th dimension
  x = reshape(x(:,ones(1,prod(s))),[length(x) s]); % Expand x
  x = permute(x,[2:i 1 i+1:nout]); % Permute to i'th dimension
  g(:,i) = x(:);
end

end
