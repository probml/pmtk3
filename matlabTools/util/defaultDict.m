function d = defaultDict(keys, values, default)
% A simple default dictionary (hashmap) similar to python's
%
% ** note, this is not an efficient data structure for large numbers of
%    key-value pairs, (i.e. more than a few hundred!). 
%
%    Consider java.util.Hashmap, (which you can call from Matlab) or
%    containers.Map.
% **
% 
%% 
% If your keys are all strings that are also valid variable names then you
% are better off just using 
% 
% d = createStruct(keys, vals), 
% d.(key)
% 
%%
%% Inputs
% keys     - a cell array of keys of any data type, (even mixed),
%            or a matrix where each *row* is interpreted as a key.
%
% values   - a cell array of values of any data type, or a matrix where
%            each *row* is interpreted as a value.
%
% default  - a value to return if the requested key is not in the dict.
%            (by default this is 0).
%
%% Output
% d        - this is just a struct, but to access the values, use
%            d.get(key), or if you want multiple values given multiple
%            keys, d.getMany(keys). See setting values below. 
%% %% Examples
%
%% Simple usage - note we request the value for a non-existent key and get
%% the default value, 42.
% keys = {'one', 'two', 'three'}';
% vals = {1, 2, 3}';
% default = 42;
% d = defaultDict(keys, vals, default);
% d.get('one')
% ans =
%     1
% d.get('foo')
% ans =
%    42
%% Getting multiple values at once
% d.getMany({'one', 'three', 'twenty'})
%ans = 
%    [ 1]
%    [ 3]
%    [42]
% The result of getMany is always a cell array, you may find unwrapCell()
% useful: 
% unwrapCell(ans) = 
% ans =
%     1
%     3
%    42
%% Keys can be any data type, and mixed, values can be a matrix where each
%% row is taken to be a value. 
% If you want a whole matrix as a value, you need to use cell arrays. 
% keys = {[1,2,3], @(x)x, 'foo'}'; 
% vals = randn(3, 5);
% d = defaultDict(keys, vals);
% d.get([1,2,3])
% ans =
%    0.0000   -1.8740    0.7310    0.6771   -0.3775
% d.get(@(x)x)  % yes a function handle as a key!
% ans =
%    0.1184   -0.3510    0.9409    0.2379    1.0823
%% Setting key value pairs
% Setting many key value pairs can be inefficient - it is better to create
% a new defaultDict. That said, you can set a value using
% d = d.set(key, val)
% *** remember to save the output variable d ***
% *** setting a key that already exists overwrites the old value without
%     warning! ***
%
%% This has a number of advantages over Matlab's container.Map
%
% (1) Its lightweight - only a few lines of code
% (2) Its not object oriented and hence works in Octave
% (3) It supports any data type, (and mixed data types) as the keys
% (4) It returns a default value if the key is not found - no need for
%     tedious isKey or isfield checks.
% PMTKslow
%%

% This file is from pmtk3.googlecode.com

ws = warning('query', 'MATLAB:printf:BadEscapeSequenceInFormat'); 
warning('off', 'MATLAB:printf:BadEscapeSequenceInFormat'); 
SetDefaultValue(1, 'keys',    {});
SetDefaultValue(2, 'values',  {});
if nargin < 3, default = 0; end
%%
if ~iscell(keys),   keys   = mat2cellRows(keys);   end
if ~iscell(values), values = mat2cellRows(values); end
keys   = colvec(keys);
values = colvec(values);
%%
K = cellfuncell(@(c)genvarname(serialize(c)), keys);
d = createStruct(K, values);
d.DEFAULT_DICT_DEFAULT = default;
d.get = @(key)get(d, key);
d.set = @(key, val)set(d, key, val);
d.getMany = @(keys)getMany(d, keys);
warning(ws); 
end


function V = get(dict, key)
% get a single value given a key
ws = warning('query', 'MATLAB:printf:BadEscapeSequenceInFormat'); 
warning('off', 'MATLAB:printf:BadEscapeSequenceInFormat'); 
K = genvarname(serialize(key));
if isfield(dict, K)
    V = dict.(K);
else
    V = dict.DEFAULT_DICT_DEFAULT;
end
warning(ws);
end

function V = getMany(dict, keys)
% vectorized version of get
keys = colvec(keys);
if ~iscell(keys)
    keys = mat2cellRows(keys);
end
V = cellfuncell(@(k)dict.get(k), keys);
end

function d = set(d, key, value)
% set a single key value pair
ws = warning('query', 'MATLAB:printf:BadEscapeSequenceInFormat'); 
warning('off', 'MATLAB:printf:BadEscapeSequenceInFormat'); 
d.(genvarname(serialize(key))) = value;

% when the dict is mutated, we must update the function handles, as they
% all implicitly store an old copy of the dictionary in their local
% workspace, (closure). 
d.get = @(key)get(d, key);
d.set = @(key, val)set(d, key, val);
d.getMany = @(keys)getMany(d, keys);
warning(ws); 
end

