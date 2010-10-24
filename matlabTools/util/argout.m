function out = argout(n, fn, varargin)
% Given a function handle and its inputs, return its nth output
% 
%% Inputs
% n        - the number of the desired output argument, e.g. 2
% fn       - a function handle or a string naming a valid function, e.g.
%            @max or 'max'
% varargin - all additional args are passed directly in to fn. 
%% Why?
%
% Allows you to create anonymous functions, which return the desired
% output. Without this, you would have to write a full function, (which
% can't live in a script!)
%
% maxidx = @(x)argout(2, @max, x); 
%
%           VS
%
% function idx = maxidx(x, varargin)
%     [j, idx] = max(x, varargin{:});
% end
%
%% Example:
%
%
% X = [5.5  9.7  11.3 2.1
%      14.3 19.1 0.5  1.4];
% maxIndex = argout(2, @max, X, [], 2)
% maxIndex =
%      3
%      2
%%
% In matlab 2009b one can finally replace j/junk with the ~ character
% but we don't here for backwards compatibility. 

% This file is from pmtk3.googlecode.com

if ischar(fn), fn = str2func(fn); end
switch n
    case 1
        out = fn(varargin{:});
    case 2
        [j1, out] = fn(varargin{:});                        %#ok 
    case 3
        [j1,j2,out] = fn(varargin{:});                      %#ok
    case 4
        [j1,j2,j3,out] = fn(varargin{:});                   %#ok
    case 5
        [j1,j2,j3,j4,out] = fn(varargin{:});                %#ok
    case 6
        [j1,j2,j3,j4,j5,out] = fn(varargin{:});             %#ok
    case 7
        [j1,j2,j3,j4,j5,j6,out] = fn(varargin{:});          %#ok
    case 8
        [j1,j2,j3,j4,j5,j6,j7,out] = fn(varargin{:});       %#ok
    case 9
        [j1,j2,j3,j4,j5,j6,j7,j8,out] = fn(varargin{:});    %#ok
    case 10
        [j1,j2,j3,j4,j5,j6,j7,j8,j9,out] = fn(varargin{:}); %#ok
    otherwise % resort to calling eval, which is less efficient, 
              % but how many functions return more than 10 arguments!
        eval(['[',repmat('j,', 1, n-1), 'out] = fn({varargin{:});']);
end      
end
