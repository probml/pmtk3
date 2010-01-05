function [y, l] = knnfwd(net, x)
%KNNFWD	Forward propagation through a K-nearest-neighbour classifier.
%
%	Description
%	[Y, L] = KNNFWD(NET, X) takes a matrix X of input vectors (one vector
%	per row)   and uses the K-nearest-neighbour rule on the training data
%	contained in NET to  produce  a matrix Y of outputs and a matrix L of
%	classification labels. The nearest neighbours are determined using
%	Euclidean distance. The IJth entry of Y counts the number of
%	occurrences that an example from class J is among the K closest
%	training examples to example I from X. The matrix L contains the
%	predicted class labels as an index 1..N, not as 1-of-N coding.
%
%	See also
%	KMEANS, KNN
%

%	Copyright (c) Ian T Nabney (1996-2001)


errstring = consist(net, 'knn', x);
if ~isempty(errstring)
  error(errstring);
end

ntest = size(x, 1);		              % Number of input vectors.
nclass = size(net.tr_targets, 2);		% Number of classes.

% Compute matrix of squared distances between input vectors from the training 
% and test sets.  The matrix distsq has dimensions (ntrain, ntest).

distsq = dist2(net.tr_in, x);

% Now sort the distances. This generates a matrix kind of the same 
% dimensions as distsq, in which each column gives the indices of the
% elements in the corresponding column of distsq in ascending order.

[vals, kind] = sort(distsq);
y = zeros(ntest, nclass);

for k=1:net.k
  % We now look at the predictions made by the Kth nearest neighbours alone,
  % and represent this as a 1-of-N coded matrix, and then accumulate the 
  % predictions so far.

  y = y + net.tr_targets(kind(k,:),:);

end

if nargout == 2
  % Convert this set of outputs to labels, randomly breaking ties
  [temp, l] = max((y + 0.1*rand(size(y))), [], 2);
end