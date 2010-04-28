function varargout = expandCells(n,varargin)

   varargout = cell(nargin-1,1);
   for i=1:numel(varargin)
      in = varargin{i};
      out = cell(n,1);
      out(1:numel(in)) = cellwrap(in);
      varargout{i} = out;
   end
   
    
end
    
    
    
    
