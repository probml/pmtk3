function addtopath(p)
% Add p to the system path. If p is already on the path, this does nothing.  
% Note, this change only persists for the duration of the Matlab session.
% Do not include path delimiters like ; or : .
% Example:
% addtopath('C:\Users\matt\bin');
    
    if isempty(getenv('PATH')) || all(cellfun(@(c)isempty(c),strfind(tokenize(getenv('PATH'),pathsep()),p)));
        setenv('PATH', [getenv('PATH'), pathsep(),p]);
    end
    
end