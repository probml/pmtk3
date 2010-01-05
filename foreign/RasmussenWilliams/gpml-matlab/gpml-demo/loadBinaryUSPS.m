% function to load digits from the usps set for a binary class task. The
% arguments specify which digits are used. The targets are +/- 1.0. The cases
% are ordered according to class. Returns x and y for training and xx and yy
% for testing.
%
% Copyright (C) 2005 and 2006, Carl Edward Rasmussen, 2006-03-13.

function [x, y, xx, yy] = loadBinaryUSPS(D1, D2);

try
  load usps_resampled.mat
catch
  disp('Error: the file usps_resampled.mat was not found. Perhaps you need to')
  disp('download the file from http://www.gaussianprocess.org/gpml/data ?')
  x = []; y = []; xx = []; yy = [];
  return
end

IND1 = train_labels(D1+1,:) == 1;           % offset by 1 as we label from zero
IND2 = train_labels(D2+1,:) == 1;
x = [train_patterns(:,IND1)'; train_patterns(:,IND2)'];
y = [ones(sum(IND1),1); -ones(sum(IND2),1)];

ITE1 = test_labels(D1+1,:) == 1;            % offset by 1 as we label from zero
ITE2 = test_labels(D2+1,:) == 1;
xx = [test_patterns(:,ITE1)'; test_patterns(:,ITE2)'];
yy = [ones(sum(ITE1),1); -ones(sum(ITE2),1)];
