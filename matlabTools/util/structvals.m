function varargout = structvals(S, varargin)
% Extract the values of a structure into an output argument list
% specify a cell array listing the  fieldnames in the order you want them
% returned. The number of output arguments must equal the number of names
% in order.
%
% Example
%
% model.mu = zeros(1, 5)
% model.Sigma = 2*eye(5)
% model.dof = 5
% [mu, Sigma, dof] = structvals(model, {'mu', 'Sigma', 'dof'})

% This file is from pmtk3.googlecode.com

if nargin < 2
   error('You must specify which fields you want to extract');  
end
if iscell(varargin{1})
    order = varargin{1};
else
    order = varargin;
end
if nargout ~= numel(order)
    error('The number of output args must equal the number of specified field names');
end
assert(nargout == numel(order));
for i=1:numel(order)
    if ~isfield(S, order{i})
        error('%s is not a field of this struct', order{i});
    end
end
order = rowvec(order);
order = [order, rowvec(setdiff(fieldnames(S), order))];
varargout = struct2cell(orderfields(S, order));

end
