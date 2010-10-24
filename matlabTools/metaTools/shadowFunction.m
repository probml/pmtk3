function shadowFunction(fname, output, quiet)
% Shadow a function so that when it is called it silently does nothing 
% rather than its default behaviour. You can optionally specify a value
% for the shadow to output. 
%
% Also accepts a cell array of function names. 
%
% **** Call removeShadows() when done ****
%
%% Examples
%
% shadowFunction('clc')
% shadowFunction({'clear', 'cls', 'pause', 'keyboard', 'placeFigures', 'input'});
% removeShadows()
%

% This file is from pmtk3.googlecode.com

SetDefaultValue(2, 'output', []); 
SetDefaultValue(3, 'quiet', false); 
warning('off', 'MATLAB:dispatcher:nameConflict');
if iscell(fname)
    cellfun(@(f)shadowFunction(f, output, quiet), fname);
    return
end
if ~quiet
fprintf('shadowing %s\n', fname); 
if endswith(fname, '.m')
    fname = fname(1:end-2);
end
end

if nargin < 2
    text = {sprintf('function %s(varargin)', fname);
        '';
        'end';
        };
else
    
    text = {sprintf('function out = %s(varargin)', fname);
        '';
            sprintf('%s', serialize(output)); 
        'end';
        };
    
end
path = fullfile(tempdir(), 'matlabShadow');
if ~exist(path, 'file')
    mkdir(fullfile(tempdir(), 'matlabShadow'));
end
writeText(text, fullfile(path, [fname, '.m']));
providePath(path);

end
