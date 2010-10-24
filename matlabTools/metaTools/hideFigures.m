function hideFigures()
% Hide all future generated figures until the showFigures() function is run

% This file is from pmtk3.googlecode.com


fprintf('figure display has been turned off\n'); 
set(0, 'defaultFigureVisible', 'off');
set(0, 'defaultAxesVisible', 'off');

tdir = tempdir();
fullpath = fullfile(tdir, 'matlabFigShadow');
if ~exist(fullpath, 'file');
    mkdir(fullpath);
end

figfile = { 'function h = figure(varargin)'
    'if nargin ==1 && isa(varargin{1}, ''double'')'
    '    if ismember(varargin{1}, get(0, ''Children''))'
    '       set(0, ''CurrentFigure'', varargin{1});'
    '       h = varargin{1};'
    '    else'
    '       h = builtin(''figure'', varargin{:});'
    '       set(gcf, ''Visible'', ''off'');'
    '    end'
    'else'
    '    h = builtin(''figure'', varargin{:}, ''visible'', ''off'');'
    'end'
    'end'
    };

axesfile = { 'function h = axes(varargin)'
    'if nargin ==1 && isa(varargin{1}, ''double'')'
    '    set(gcf, ''currentAxes'', varargin{1});'
    '    h = varargin{1};'
    'else'
    '    h = builtin(''axes'', varargin{:}, ''visible'', ''off'');'
    'end'
    'end'
    };

writeText(figfile, fullfile(fullpath, 'figure.m'));
writeText(axesfile, fullfile(fullpath, 'axes.m'));
warning('off', 'MATLAB:dispatcher:nameConflict')
providePath(fullpath);





end
