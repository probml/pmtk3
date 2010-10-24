function [S1, S2] = moveFields(fields, S1, S2)
%% Move fields from struct S1 to struct S2

% This file is from pmtk3.googlecode.com


if nargin < 3
    S2 = struct();
end
for i=1:numel(fields)
   f      = fields{i};
   S2.(f) = S1.(f); 
   S1     = rmfield(S1, f); 
end
   
end
