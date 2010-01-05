function datwrite(filename, x, t)
%DATWRITE Write data to ascii file.
%
%	Description
%
%	DATWRITE(FILENAME, X, T) takes a matrix X of input vectors and a
%	matrix T of target vectors and writes them to an ascii file named
%	FILENAME. The file format is as follows: the first row contains the
%	string NIN followed by the number of inputs, the second row contains
%	the string NOUT followed by the number of outputs, and the third row
%	contains the string NDATA followed by the number of data vectors.
%	Subsequent lines each contain one input vector followed by one output
%	vector, with individual values separated by spaces.
%
%	See also
%	DATREAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

nin = size(x, 2);
nout = size(t, 2);
ndata = size(x, 1);

fid = fopen(filename, 'wt');
if fid == -1
  error('Failed to open file.')
end

if size(t, 1) ~= ndata
  error('x and t must have same number of rows.');
end

fprintf(fid, ' nin   %d\n nout  %d\n ndata %d\n', nin , nout, ndata);
for i = 1 : ndata
  fprintf(fid, '%13e ', x(i,:), t(i,:));
  fprintf(fid, '\n');
end

flag = fclose(fid);
if flag == -1
  error('Failed to close file.')
end

