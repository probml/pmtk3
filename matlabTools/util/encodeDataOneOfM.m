function dataNew = encodeDataOneOfM(data, nClass, classSize);
% returns one of M encoding of the data according to number of classes nClass.
% Data should be #dim x #measurments
% if classSize is 'M+1' then only first nClass-1 bits are returned.
% if classSize is 'M' then all the bits are returned
  if nargin==2
    classSize = 'M+1';
  end

  if strcmp(classSize, 'M+1')
    nClass = nClass -1;
  end

  M = nClass;
  [D,N] = size(data);
  dataNew = [];
  for d = 1:D
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    miss = isnan(data(d,:));
    dataNew(idx,:) = bsxfun(@eq, data(d,:), [1:nClass(d)]');
    dataNew(idx,miss) = NaN;
  end

