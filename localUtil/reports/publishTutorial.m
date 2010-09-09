function publishTutorial()
%% Publish the pmtk tutorial.
% Remember to do an SVN checkin after running.
% The wiki pages at http://code.google.com/p/pmtk3/wiki/Tutorial
% are manually created - they link to the matlab-generated
% html pages.
%%

% This file is from pmtk3.googlecode.com

recursive = false; 
exclusions = {'html', 'attic'};  % no need to exclude if recursive is false
src = fullfile(pmtk3Root(), 'docs', 'tutorial');
tutFiles = filelist(src, '*.m', recursive); 
if recursive
   for i=1:numel(exclusions)
      tutFiles = setdiff(tutFiles, fullfile(src, exclusions{i}), '*.m', recursive); 
   end
end

for i=1:numel(tutFiles)
  fprintf('publishing %s\n', tutFiles{i});
   pmtkPublish(tutFiles{i});  
end



end
