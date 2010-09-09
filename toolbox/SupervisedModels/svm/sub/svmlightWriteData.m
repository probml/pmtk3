function svmlightWriteData(X, y, fname, yformat)
% Write data in svm_light format
% X is nexamples-by-nfeatures
% y is nexamples-by-1
% fname is the file name to which the data will be written.

% This file is from pmtk3.googlecode.com


[n, d] = size(X);
data = zeros(n, 2*d+1);
data(:, 1) = y;
data(:, 2:2:end) = repmat(1:d, n, 1);
data(:, 3:2:end) = X;
format = [yformat, repmat(' %d:%f', 1, d), '\n'];
fid = fopen(fname, 'w');
data = data';
fprintf(fid, format, data); % data gets written out column by column
fclose(fid);


end
