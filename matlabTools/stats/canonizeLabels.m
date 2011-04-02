function [canonized, support] = canonizeLabels(labels,support)
%% Transform labels to 1:K
% The size of canonized is the same as labels but every
% label is transformed to its corresponding entry in 1:K. If labels does not
% span the support, specify the support explicitly as the 2nd argument. 
%
% Examples:
%%
% str = {'yes'    'no'    'yes'    'yes'    'maybe'    'no'    'yes'  'maybe'};
%     
% canonizeLabels(str)
% ans =
%      3     2     3     3     1     2     3     1
%%
%canonizeLabels([3,5,8,9; 0,0,-3,2])
%ans =
%     4     5     6     7
%     2     2     1     3
%
%%
% Suppose we know the support is say 10:20 but our labels are [11:15,17,19] and
% we want 11 to be coded as 2 since our support begins at 10 and similarly
% 19 codes as 10 and 20 as 11. We can specify the actual support to achieve
% this.
%
% canonizeLabels([10,11,19,20])          - without specifying support
% ans =  1     2     3     4
%    
% canonizeLabels([10,11,19,20],10:20)        - with specifying support
% ans =  1     2    10    11
% 
%
% To make 0,1 use canonizeLabels(y)-1
% To make -1,+1 use (2*(canonizeLabels(y)-1))-1

% This file is from pmtk3.googlecode.com




[nrows,ncols] = size(labels);
labels = labels(:);

if(nargin == 2)
  labels = [labels;support(:)];
end

if(ischar(labels))
  [s,j,canonized] = unique(labels,'rows');
elseif(issparse(labels))
  labels = double(full(labels));
  [s,j,canonized] = unique(labels);
else
  [s,j,canonized] = unique(labels);
end

if(nargin == 2)
  if(~isequal(support(:),s(:)))
    error('Some of the data lies outside of the support.');
  end
  canonized(end:-1:end-numel(support)+1) = [];
end
support = s;
canonized = reshape(canonized,nrows,ncols);
if ~iscell(labels)
  canonized(isnan(labels))=nan;
end
end
