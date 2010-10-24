function previewPublished(fname, evalCode, outputDir)
%% Preview what the published result of the demo will look like
%
% If evalCode is set to false, (default true), the demo is not run and only
% text is published. 
%% Example
% publishPreview mixGaussVbDemoFaithful
% PMTKneedsMatlab 

% This file is from pmtk3.googlecode.com

close all;
SetDefaultValue(2, 'evalCode', true);
SetDefaultValue(3, 'outputDir', tempdir()); 

options.evalCode = evalCode;
options.outputDir = outputDir;
options.format = 'html';
options.createThumbnail = false;
publish(which(fname), options);
web(fullfile(outputDir, [filenames(fname), '.html'])); 
close all;


end
