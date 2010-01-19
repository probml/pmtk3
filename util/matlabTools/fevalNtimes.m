function C = fevalNtimes(fnstr,n,varargin)
    
   C = cell(n,1);
   for i=1:n
      C{i} = feval(fnstr,varargin{:}); 
   end
    
end