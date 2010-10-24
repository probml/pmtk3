function varargout = compileAndRun(fname,varargin)
% Compile a Matlab function via emlmex and then run the compiled version.
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
% If you will call the compiled version multiple times with the same size,
% type and number of inputs, use the compileRunAndSave() function instead.
%
% PMTKneedsMatlab 2008
%%

% This file is from pmtk3.googlecode.com

    
    if(~exist('emlmex','file'))
        error('emlmex could not be found');
    end
    
    clear mex;
    if(~exist(fname,'file'))
       error('%s could not be found',fname); 
    end
 
    prevDirectory = pwd;
    cd(fileparts(which(fname)));
    try
        fprintf('\ncompiling %s...\n',fname);
        tic;
        emlmex(fname,'-eg',varargin);
        t = toc;
        fprintf('\ncompiled successfully in %g seconds\n',t);
    catch
        warning('compileAndRun:mex','\n\ncould not compile, performance might be slow.\n\n');
    end 
    fprintf('\nexecuting function...\n');
    tic
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

    clear mex;
    delete([fname,'.',mexext]);
    cd(prevDirectory);
    t = toc;
    fprintf('\n%s ran in %g seconds.\n',fname,t);
end
