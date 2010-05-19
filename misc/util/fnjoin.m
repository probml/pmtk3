function varargout = fnjoin(input, varargin)
% Create a single function that applies multiple functions to a single input
% 
% For example, to combine objective and gradient functions into one use
% [f, g] = fnjoin(w, @obj, @grad) % useful for optimization
%%
varargout = {};
in = cellwrap(input); 
for i=1:numel(varargin)
    varargout{i} = varargin{i}(in{:});
end

end
