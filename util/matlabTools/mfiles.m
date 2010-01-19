function m = mfiles(varargin)
% list all mfiles in the specified directory structure.     
   
   
    [source,topOnly] = processArgs(varargin,'-source',pwd(),'-topOnly',false);
    
    if topOnly
        I = what(source);
        m = I.m;
    else
        [dirinfo,m] = mfilelist(source); 
        m = m';
    end
    
end