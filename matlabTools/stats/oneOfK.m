function [yy,map] = oneOfK(y, K)
% Convert class labels to a one of K encoding 
% (see also dummyEncoding)
% The class labels are first converted to 1:K. The number of class labels
% is automatically infered. If K is explicitly specified, the class support
% is forced to be contiguous. The output map stores the unique elements of
% y. 
% 
% INPUT: 
%
% y         - the original class labels: e.g [1,3,3,2,2,4] or , [-1,1,1,1,-1], 
%             or [0,1], or even {'yes','no','maybe'}
%
% K         - optional: explicitly specify the number of class labels if the
%             number of desired classes exceeds the number of unique labels. 
%             Specifying K forces a contiguous class support in 1:K.
%
% OUTPUT:
%
% yy        - the one of k encoding of the class labels. Let ymapped be the
%             mapping of y to 1:K, then yy(n,:) is a K dimensional bit vector, 
%             where yy(n, ymapped(n)) = 1
%             
% map       - a map from 1:K back to the original unique elements of y, i.e.
%             map(i) is the ith unique element of y.
%
% EXAMPLES:
%%
% [yy,map] = oneOfK([1,2,1,3],4)
% yy =
%      1     0     0     0
%      0     1     0     0
%      1     0     0     0
%      0     0     1     0
% map = 
%     [1]    [2]    [3]    [4]
%%
% [yy,map] = oneOfK({'yes','no','yes','maybe'}) 
% yy =
%      0     0     1
%      0     1     0
%      0     0     1
%      1     0     0
% map = 
%     'maybe'    'no'    'yes'
%%
% [yy,map] = oneOfK([-1,-1,1,-1,-1,1,-1])
% yy =
%      1     0
%      1     0
%      0     1
%      1     0
%      1     0
%      0     1
%      1     0
% map = 
%     [-1]    [1]
%%
% [yy,map] = oneOfK(['yes  ';'no   ';'maybe'])
% yy =
%      0     0     1
%      0     1     0
%      1     0     0
% map = 
%     'maybe'
%     'no'
%     'yes'
%%

% This file is from pmtk3.googlecode.com

if(ischar(y)), y = cellstr(y);end      % character arrays, where rows are labels

[map,junk,ymapped] = unique(y);                                                 %#ok
nunique = length(map);
if(nargin == 2 && nunique ~=K)
    if(K < nunique)
        error('K is less than the number of unique labels in y - oneOfK does not know which ones to remove.');
    end
    if(~isnumeric(y))
        error('You have specified more classes, K, than unique strings, y, and oneOfK cannot infer the missing class labels.');
    end
    
    if(~isempty(setdiff(map,1:K)))
       error('When K is explicitly specified and differs from numel(unique(y)), y cannot contain any labels outside of the range 1:K'); 
    end
    
    ymapped = ymapped + numel(1:map(1)-1);
    map = 1:K;
else
   K = nunique; 
end

N = length(ymapped);
yy = zeros(N, K);
ndx = sub2ind(size(yy), 1:N, ymapped(:)');
yy(ndx) = 1;

end
