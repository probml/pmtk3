function varargout = unitTest(fname, varargin)
%% Run all of the demos that depend on fname. 
% 
%% Inptus
%
% fname  - the name of the function, e.g. 'minFunc'.
% 
%% Optional named inputs [default]
%  
% 'run'         - [true] run the demos instead of just returing their names
% 'recursive'   - [true] include long range dependencies
% 'recache'     - [false] tell whoCallsMe to recache its dependency info
% 'excludeTags' - [{}] don't include demos that have these tags
% 'debug'       - [false] keep running even if a demo fails
%
%% Output
% 
% demos         - a list of demos that depend on fname
% errors        - if run && debug, return a list of errors if any.
% 
%% Examples
%
% unitTest minFunc
% unitTest('hmmFwdBack', 'excludeTags', {'PMTKslow'}, 'debug', true)
% demos = unitTest('gaussLogprob', 'run', false); 
%% See also
% debugDemos
% runDemos
% runAllDemos
% processExamples
%%

% This file is from pmtk3.googlecode.com

[run, recursive, recache, excludeTags, debug] = process_options(varargin,...
    'run'       , true  , ...
    'recursive' , true   , ...
    'recache'   , false  , ...
    'excludeTags', {}     , ...
    'debug'    , false);

callList = whoCallsMe(fname, 'recursive', recursive, 'recache', recache);
demos = intersect(callList, mfiles(fullfile(pmtk3Root(), 'demos'), 'removeExt', true));
keep = [];
for i=1:numel(demos)
    tags = tagfinder(demos{i});
    if isempty(intersect(excludeTags, tags));
        keep = [keep, i]; %#ok
    end
end
demos = demos(keep);
if isempty(demos)
    fprintf('no dependent demos could be found\n'); 
    return;
end

maxname = max(cellfun(@length, demos));
errors = {};
if run
    if ~debug
        for i=1:numel(demos)
            localEval(demos{i});
        end
    else
        clc;
        fprintf('*** Unit Testing %d Demos ***\n\n', numel(demos));
        for i=1:numel(demos)
            try
                fprintf('%d:%s %s%s',i, repmat(' ', [1, 5-length(num2str(i))]),...
                    demos{i}, dots(maxname+5-length(demos{i})));
                localEvalc(demos{i});
                fprintf('OK\n');
            catch ME
                fprintf(2, 'FAIL\n');
                errors = insertEnd(ME, errors);
            end
        end
    end
end
if nargout > 0 || ~run
    varargout{1} = demos;
end
if nargout > 1
    varargout{2} = errors;
end


end

function localEvalc(demo)
% run the demo in *this* workspace
close all;
close all hidden;
evalc(demo);
end

function localEval(demo)
% run the demo in *this* workspace
close all;
close all hidden;
eval(demo);
end
