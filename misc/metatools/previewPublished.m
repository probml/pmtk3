function previewPublished(fname, evalCode)
%% Preview what the published result of the demo will look like
%
% If evalCode is set to false, (default true), the demo is not run and only
% text is published. 
%% Example
% publishPreview mixGaussVbDemoFaithful
close all;
SetDefaultValue(2, 'evalCode', true);

options.evalCode = evalCode;
options.outputDir = tempdir();
options.format = 'html';
options.createThumbnail = false;
publish(which(fname), options);
web(fullfile(tempdir(), [fname, '.html'])); 
close all;


end