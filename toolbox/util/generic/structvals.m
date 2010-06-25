function varargout = structvals(S, order)
% Extract the values of a structure into an output argument list
% in alphabetical order. You can optionally specify a cell array listing the
% fieldnames in the order you want them returned. 
%
% Example 
%
% model.mu = zeros(1, 5)
% model.Sigma = 2*eye(5)
% model.dof = 5
% [dof, mu, Sigma] = structvals(model) % returned in alphabetical order
%       OR
% [mu, Sigma, dof] = structvals(model, {'mu', 'Sigma', 'dof'}) % returned in specified order
    switch nargin
        case 1
            varargout = struct2cell(orderfields(S, sortidx(cellfuncell(@lower, fieldnames(S)))));
        case 2
            varargout = struct2cell(orderfields(S, order));
    end
end