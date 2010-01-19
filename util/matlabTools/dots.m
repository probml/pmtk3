function out = dots(n)
    if nargout > 0
        out = sprintf('%s',repmat('.',1,n));
    else
        fprintf('%s',repmat('.',1,n)) 
    end
end