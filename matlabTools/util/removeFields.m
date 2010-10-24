function S = removeFields(S, varargin)
%% Remove multiple fields from a structure without erroring if they don't exist

% This file is from pmtk3.googlecode.com

fields = varargin;
for i=1:numel(fields)
    field = fields{i};
    if isfield(S, field)
        S = rmfield(S, field);
    end
end
end
