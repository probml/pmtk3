function f = curry(fn,varargin)
    
   args = varargin;
   f = @(varargin)fn(varargin{:},args{:});
    
    
end