function errstring = consist(model, type, inputs, outputs)
%CONSIST Check that arguments are consistent.
%
%	Description
%
%	ERRSTRING = CONSIST(NET, TYPE, INPUTS) takes a network data structure
%	NET together with a string TYPE containing the correct network type,
%	a matrix INPUTS of input vectors and checks that the data structure
%	is consistent with the other arguments.  An empty string is returned
%	if there is no error, otherwise the string contains the relevant
%	error message.  If the TYPE string is empty, then any type of network
%	is allowed.
%
%	ERRSTRING = CONSIST(NET, TYPE) takes a network data structure NET
%	together with a string TYPE containing the correct  network type, and
%	checks that the two types match.
%
%	ERRSTRING = CONSIST(NET, TYPE, INPUTS, OUTPUTS) also checks that the
%	network has the correct number of outputs, and that the number of
%	patterns in the INPUTS and OUTPUTS is the same.  The fields in NET
%	that are used are
%	  type
%	  nin
%	  nout
%
%	See also
%	MLPFWD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Assume that all is OK as default
errstring = '';

% If type string is not empty
if ~isempty(type)
  % First check that model has type field
  if ~isfield(model, 'type')
    errstring = 'Data structure does not contain type field';
    return
  end
  % Check that model has the correct type
  s = model.type;
  if ~strcmp(s, type)
    errstring = ['Model type ''', s, ''' does not match expected type ''',...
	type, ''''];
    return
  end
end

% If inputs are present, check that they have correct dimension
if nargin > 2
  if ~isfield(model, 'nin')
    errstring = 'Data structure does not contain nin field';
    return
  end

  data_nin = size(inputs, 2);
  if model.nin ~= data_nin
    errstring = ['Dimension of inputs ', num2str(data_nin), ...
	' does not match number of model inputs ', num2str(model.nin)];
    return
  end
end

% If outputs are present, check that they have correct dimension
if nargin > 3
  if ~isfield(model, 'nout')
    errstring = 'Data structure does not conatin nout field';
    return
  end
  data_nout = size(outputs, 2);
  if model.nout ~= data_nout
    errstring = ['Dimension of outputs ', num2str(data_nout), ...
	' does not match number of model outputs ', num2str(model.nout)];
    return
  end

% Also check that number of data points in inputs and outputs is the same
  num_in = size(inputs, 1);
  num_out = size(outputs, 1);
  if num_in ~= num_out
    errstring = ['Number of input patterns ', num2str(num_in), ...
	' does not match number of output patterns ', num2str(num_out)];
    return
  end
end
