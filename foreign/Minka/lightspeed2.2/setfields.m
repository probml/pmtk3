function ab = setfields(a, b, newfield_flag)
%SETFIELDS   Set multiple fields of a structure.
% SETFIELDS(A,B), where A and B are structures, returns a copy of A where
% the fields named in B have the values specified in B.  If B contains fields
% not in A, signals an error.
% SETFIELDS(A,B,'create') allows B to contain new fields, which are added to A.
% SETFIELDS(A,B,'ignore') ignores new fields in B.
%
% Examples:
%   a.a = 1
%   b.b = 2
%   setfields(a,b)   % error
%   setfields(a,b,'create')  % ans = struct('a',1,'b',2)
%   setfields(a,b,'ignore')  % ans = struct('a',1)

% Written by Tom Minka,
% based on mergestruct.m by Martin Szummer and Yuan Qi.
% (The arguments are flipped with respect to mergestruct.)
% (c) Microsoft Corporation. All rights reserved.

if nargin < 3
  newfield_flag = '';
end
ab = a;
if isempty(b)
  return
end
bfields = fieldnames(b);
switch newfield_flag
  case 'create'
    % do nothing
  case 'ignore'
    existing = ismember(bfields, fieldnames(a));
    bfields = bfields(find(existing));
  case ''
    existing = ismember(bfields, fieldnames(a));
    if any(~existing)
      a
      b
      error('attempt to set non-existent fields');
    end
  otherwise
    error('unrecognized option');
end
   
for i = 1:length(bfields)
  ab = setfield(ab, bfields{i}, getfield(b, bfields{i}));
end
