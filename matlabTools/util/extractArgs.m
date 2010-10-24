function varargout = extractArgs(indices,args)
% Extract specified arguments / values from the output of processArgs
% also returning the unused name/value pairs in a cell array. 
%
% When processArgs is called with exactly one output, the output contains
% all of the name value pairs in a single cell array. The values are either
% the programmer specified defaults, or if specified, the user values.
% 
% This function returns the requested arg values in the order they were
% requested, (not the corresponding names). However, the unused name value
% pairs are returned as the last output argument, bundled in a cell array.
% This can be then be passed to another function. 
%
% Example:
% 
% function [beta,delta,epsilon] = outerFunction(varargin)
%   args = processArgs(varargin,'-alpha',1,'-beta',2,'-gamma',3,'-delta',4) 
%   [beta,delta,unused] = extractArgs([2,4],args);
%   epsilon = anotherFunction(unused{:});
% end

% This file is from pmtk3.googlecode.com



    valIDX  = 2:2:numel(args);
    nameIDX = 1:2:numel(args);
    vals = args(valIDX(indices));
    args(union(valIDX(indices),nameIDX(indices))) = [];
    varargout = [vals,{args}];
   
   
end
