function classes = getClasses(varargin)
% Get a list of all of the classes below the specified directory 
% that are  on the Matlab path. You can optionally specify directories to
% ignore. By default, the util and unitTests directories are ignored.
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com

    
[source,ignoreDirs,topOnly] = process_options(varargin,'source',pwd(),'ignoreDirs',{},'topOnly',false);

if nargin < 1, source = '.'; end
if nargin < 2, 
if nargin < 3,  ignoreDirs = {}; end
   if exist('PMTKroot.m','file')
       if ~strcmpi(source,fullfile(PMTKroot(),'util'))
           ignoreDirs = [ignoreDirs;fullfile(PMTKroot(),'util')];
       end
       if ~strcmpi(source,fullfile(PMTKroot(),'unitTests'))
           ignoreDirs = [ignoreDirs;fullfile(PMTKroot(),'unitTests')];
       end
   end
end

classes = filterCell(cellfuncell(@(c)c(1:end-2),mfiles(source,topOnly)),@(m)isclassdef(m));
for i=1:numel(ignoreDirs)
   classes = setdiff(classes, filterCell(cellfuncell(@(c)c(1:end-2),mfiles(ignoreDirs{i})),@(m)isclassdef(m)));
end

end
