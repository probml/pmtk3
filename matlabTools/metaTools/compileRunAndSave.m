function varargout = compileRunAndSave(fname,varargin)
% Similar to compileAndRun except the mex file is not deleted.
% If the mex file exists, then this function tries to use it and only
% compiles a new copy if that fails. This version is useful when a function
% will be called over and over again with the same sized inputs as is the
% case with cross validation for instance. This version does not print
% anything to the screen. Use compileAndRun to debug.
%
% The function must reside in its own file and be eml compliant. See the
% help sections on emlmex for details.
%
% fname     - the string name of the function
% varargin  - arguments to the compiled function
%
% Example:
%
% [a b c] = compileAndRun('myfunction',X,Y,Z,3); % where X,Y,Z,3 are inputs
%           to 'myfunction', which returns three outputs.
%
%
% PMTKneedsMatlab 

% This file is from pmtk3.googlecode.com


if(~exist('emlmex','file'))
    error('Sorry, emlmex could not be found');
end

query = exist(fname,'file');
if(query == 0)
    error('%s could not be found',fname);
end
if(query == 3)  % mex file exists
    try
        nout = nargout([fname,'.m']);
        varargout = {};
        if(nout == 0)
            feval(fname,varargin{:});
        elseif(nout < 0)
            varargout{1} = feval(fname,varargin{:});
        else
            out = '[';
            for i=1:nout
                out = [out,sprintf(' varargout{%d} ',i)]; %#ok
            end
            out = [out,']'];
            eval([out,' = ','feval(fname,varargin{:})']);
        end
        return;
    catch
    end
end



prevDirectory = pwd;
cd(fileparts(which(fname)));
try
    emlmex(fname,'-eg',varargin);
catch
    error('compileRunAndSave:mex','\n\ncould not compile');
end

nout = nargout([fname,'.m']);
varargout = {};
if(nout == 0)
    feval(fname,varargin{:});
elseif(nout < 0)
    varargout{1} = feval(fname,varargin{:});
else
    out = '[';
    for i=1:nout
        out = [out,sprintf(' varargout{%d} ',i)]; %#ok
    end
    out = [out,']'];
    eval([out,' = ','feval(fname,varargin{:})']);
end


cd(prevDirectory);

end
