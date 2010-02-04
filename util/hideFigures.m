function hideFigures()
% Hide all future generated figures until the showFigures() function is
% run. 
    
    set(0, 'defaultFigureVisible', 'off');
    set(0, 'defaultAxesVisible', 'off');
    
    tdir = tempdir();
    fullpath = fullfile(tdir, 'matlabShadow'); 
    if ~exist(fullpath, 'file');
        mkdir(fullpath);
    end
    
    figfile = { 'function h = figure(varargin)'
                'if nargin ==1 && isa(varargin{1}, ''double'')'
                '    builtin(''figure'', varargin{1});'
                '    set(gcf, ''visible'', ''off'');'
                '    h = varargin{1};'
                'else'
                '    h = builtin(''figure'', varargin{:}, ''visible'', ''off'');'
                'end'
              };
        
    axesfile = { 'function h = axes(varargin)'
                 'if nargin ==1 && isa(varargin{1}, ''double'')'
                 '    builtin(''axes'', varargin{1});'
                 '    set(gca, ''visible'', ''off'');'
                 '    h = varargin{1};'
                 'else'
                 '    h = builtin(''axes'', varargin{:}, ''visible'', ''off'');'
                 'end'
               };    
    
    writeText(figfile, fullfile(fullpath, 'figure.m'));
    writeText(axesfile, fullfile(fullpath, 'axes.m'));
    warning('off', 'MATLAB:dispatcher:nameConflict')
    providePath(fullpath);
    
    
   
    
 
end