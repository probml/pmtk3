function m = serialize(v, n)
% Create a string representation S, of a variable v, s.t. eval(S) = v
%  
%   matcode = SERIALIZE(x) generates matlab code of x
%   matcode = SERIALIZE(x, n) generates matlab code of x retaining n digits
%   of precision
%   SERIALIZE() enters self test mode
%
%   SERIALIZE should be able to create matlab code of the following data types:
%   - matrices, vectors, and scalars of any class and dimension
%   - strings
%   - structs, arrays of structs with up to six dimensions 
%   - cell arrays
%   - matlab objects with a copy constructor implemented (Not Java)
%   - empty values of any class
%   - any combinations hereof
%  
%   The value of x can be obtained by
%     eval(matcode)
%
%   Examples 
%     x = [1 2 3; 3 4 5];
%     serialize(x)
%     
%     x = uint8(rand(10)*5);
%     matcode = serialize(x)
%
%     x = {rand(3,3,3,4), 'a string value', {1 2 3; 1 3 3 }}
%     matcode = serialize(x, 30)
%
%   See also mat2str, num2str, int2str, sprintf, class, eval

% This file is from pmtk3.googlecode.com


%% AUTHOR    : Joger Hansegard 
%% $DATE     : 29-Jun-2006 17:37:49 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 7.2.0.232 (R2006a) 
%% FILENAME  : serialize.m 
%PMTKauthor Joger Hansegard
switch nargin
  case 0
    selftest()
    return;
  case 1
    n = 15;
end

val = serializevalue(v, n);
m = [val ';'];
end
%
% Main hub for serializing values
%
function val = serializevalue(v, n)
if isnumeric(v) || islogical(v)
  val = serializematrix(v, n);
elseif ischar(v)
  val = serializestring(v, n);
elseif isstruct(v)
  val = serializestruct(v, n);
elseif iscell(v)
  val = serializecell(v, n);
elseif isobject(v)
  val = serializeobject(v, n);
elseif isa(v, 'function_handle')
  val = serializehandle(v); 
else
  error('Unhandled type %s', class(v));
end
end
%
% Serialize a string
% 
function val = serializestring(v,n)
val              = ['sprintf(''' v ''')'];
doConvertToUint8 = false;
try
  dummy = eval(val);
catch
  doConvertToUint8 = true;
end
if doConvertToUint8 || ~isequal(eval(val), v) 
  val = ['char(' serializevalue(uint8(v), n) ')'];
end
end

%
% Serialize a matrix and apply correct class and reshape if required
%
function val = serializematrix(v, n)
if ndims(v) < 3
  if isa(v, 'double')
    val = mat2str(v, n);
  else
    val = mat2str(v, n, 'class');
  end
else
  if isa(v, 'double')
    val = mat2str(v(:), n);
  else
    val = mat2str(v(:), n, 'class');
  end
  val = sprintf('reshape(%s, %s)', val, mat2str(size(v)));
end
end
%
% Serialize a cell
%
function val = serializecell(v, n)
if isempty(v)
  val = '{}';
  return
end
cellSep = ', ';
if isvector(v) && size(v,1) > 1
  cellSep = '; ';
end

% Serialize each value in the cell array, and pad the string with a cell
% separator.
vstr = cellfun(@(val) [serializevalue(val, n) cellSep], v, 'UniformOutput', false);
vstr{end} = vstr{end}(1:end-2);

% Concatenate the elements and add a reshape if requied
val = [ '{' vstr{:} '}'];
if ~isvector(v)
  val = ['reshape('  val sprintf(', %s)', mat2str(size(v)))];
end
end
%
% Serialize a struct by converting the field values using struct2cell
%
function val = serializestruct(v, n)
fieldNames   = fieldnames(v);
fieldValues  = struct2cell(v);
if ndims(fieldValues) > 6
  error('Structures with more than six dimensions are not supported');
end
val = 'struct(';
for fieldNo = 1:numel(fieldNames)
  val = [val serializevalue( fieldNames{fieldNo}, n) ', '];
  val = [val serializevalue( permute(fieldValues(fieldNo, :,:,:,:,:,:), [2:ndims(fieldValues) 1]) , n) ];
  val = [val ', '];
end
val = [val(1:end-2) ')'];
if ~isvector(v)
  val = sprintf('reshape(%s, %s)', val, mat2str(size(v)));
end
end
%
% Serialize an object by converting to struct and add a call to the copy
% contstructor
%
function val = serializeobject(v, n)
val = sprintf('%s(%s)', class(v), serializevalue(struct(v), n));
end

function val = serializehandle(v)
    val = sprintf('str2func(''%s'')', func2str(v));
end

%
% Self test
%
function selftest()
% Create some test data

% Strings
teststr1  = 'Backslash: \\ Percent: % Carriage return: \r Form feed: \f Tabulator: \t Newline: \n Comment: %% Star: * FileName: c:\\test\\filename.txt c:/test/filename.txt Question: ?  ';
teststr2  = sprintf('%s', teststr1);
teststr3  = [char(1:255) '\n Test of all ascii characters'];
dotest('String test one', teststr1);
dotest('String test two', teststr2);
dotest('String test three', teststr3);

% Numeric data
doublematrix  = rand(10, 10, 1, 4);
singlematrix  = single(rand(10, 10, 2));
uint8matrix   = uint8(singlematrix*10);
charmatrix    = char(0:255);
dotest('Double matrix', doublematrix, 20) % Extra precision for doubles
dotest('Single matrix', singlematrix)
dotest('Uint8 matrix',  uint8matrix)
dotest('Char matrix',   charmatrix);

% Structs and cells
a.x{1}    = sprintf('%s', teststr1);
a.x{2}    = teststr1;
a.teststr = teststr2;
a.b.anotherteststr = teststr3; 
a.c{2}    = cell(10,10,8, 2);
dotest('Structs and cells', a);

end
%
% Helper for self test
%
function dotest(description, val, precision)

if nargin == 2
  stringval = serialize(val);
else
  stringval = serialize(val, precision);
end

try
if ~isequal(eval(stringval), val)
  error('%s failed', description);
else
  disp(sprintf('%s passed', description));
end
catch
  error('%s failed', description);
end

end
% Created by: J?ger Hanseg?rd
% Contact...: jogerh@ifi.uio.no
% ===== EOF ====== [serialize.m] ======
