function m = mfiles(source, varargin)
% list all mfiles in the specified directory structure.     
   
    if nargin == 0, source = pwd(); end
    [topOnly] = process_options(varargin,'topOnly',false);
    
    if topOnly
        I = what(source);
        m = I.m;
    else
        [dirinfo,m] = mfilelist(source); 
        m = m';
    end
    
end