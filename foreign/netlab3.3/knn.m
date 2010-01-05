function net = knn(nin, nout, k, tr_in, tr_targets)
%KNN	Creates a K-nearest-neighbour classifier.
%
%	Description
%	NET = KNN(NIN, NOUT, K, TR_IN, TR_TARGETS) creates a KNN model NET
%	with input dimension NIN, output dimension NOUT and K neighbours.
%	The training data is also stored in the data structure and the
%	targets are assumed to be using a 1-of-N coding.
%
%	The fields in NET are
%	  type = 'knn'
%	  nin = number of inputs
%	  nout = number of outputs
%	  tr_in = training input data
%	  tr_targets = training target data
%
%	See also
%	KMEANS, KNNFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)


net.type = 'knn';
net.nin = nin;
net.nout = nout;
net.k = k;
errstring = consist(net, 'knn', tr_in, tr_targets);
if ~isempty(errstring)
  error(errstring);
end
net.tr_in = tr_in; 
net.tr_targets = tr_targets;

