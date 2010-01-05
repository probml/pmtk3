function [x, t, nin, nout, ndata] = datread(filename)
%DATREAD Read data from an ascii file.
%
%	Description
%
%	[X, T, NIN, NOUT, NDATA] = DATREAD(FILENAME) reads from the file
%	FILENAME and returns a matrix X of input vectors, a matrix T of
%	target vectors, and integers NIN, NOUT and NDATA specifying the
%	number of inputs, the number of outputs and the number of data points
%	respectively.
%
%	The format of the data file is as follows: the first row contains the
%	string NIN followed by the number of inputs, the second row contains
%	the string NOUT followed by the number of outputs, and the third row
%	contains the string NDATA followed by the number of data vectors.
%	Subsequent lines each contain one input vector followed by one output
%	vector, with individual values separated by spaces.
%
%	See also
%	 nin   2   nout  1   ndata 4   0.000000e+00  0.000000e+00
%	1.000000e+00    0.000000e+00  1.000000e+00  0.000000e+00
%	1.000000e+00  0.000000e+00  0.000000e+00    1.000000e+00
%	1.000000e+00  1.000000e+00   See Also
%	DATWRITE
%

%	Copyright (c) Ian T Nabney (1996-2001)

fid = fopen(filename, 'rt');
if fid == -1
  error('Failed to open file.')
end

% Read number of inputs
s1 = fscanf(fid, '%s', 1);
if ~strcmp(s1, 'nin')
  fclose(fid);
  error('String ''nin'' not found')
end
nin   = fscanf(fid, '%d\n', 1);
if ~isnumeric(nin)
  fclose(fid);
  error('No number for nin')
end
if nin < 0 | round(nin) ~= nin
  fclose(fid);
  error('nin must be a non-negative integer')
end

% Read number of outputs
s2 = fscanf(fid, '%s', 1);
if ~strcmp(s2, 'nout')
  fclose(fid);
  error('String ''nout'' not found')
end
nout  = fscanf(fid, '%d\n', 1);
if ~isnumeric(nout)
  fclose(fid);
  error('No number for nout')
end
if nout < 0 | round(nout) ~= nout
  fclose(fid);
  error('nout must be a non-negative integer')
end

% Read number of data values
s3 = fscanf(fid, '%s', 1);
if ~strcmp(s3, 'ndata')
  fclose(fid);
  error('String ''ndata'' not found')
end
ndata = fscanf(fid, '%d\n', 1);
if ~isnumeric(ndata)
  fclose(fid);
  error('No number for ndata')
end
if ndata < 0 | round(ndata) ~= ndata
  fclose(fid);
  error('ndata must be a non-negative integer')
end

% The following line reads all of the remaining data to the end of file.
temp  = fscanf(fid, '%f', inf);

% Check that size of temp is correct
if size(temp, 1) * size(temp,2) ~= (nin+nout) * ndata
  fclose(fid);
  error('Incorrect number of elements in file')
end

temp = reshape(temp, nin + nout, ndata)';
x = temp(:, 1:nin);
t = temp(:, nin + 1 : nin + nout);

flag = fclose(fid);
if flag == -1
  error('Failed to close file.')
end

