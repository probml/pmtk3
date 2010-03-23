function R = missingTitleReport()
% Generate a list of PMTK3 demos that are missing titles.
demos = processExamples({}, {}, 0, false)';
R = filterCell(demos, @missingTitle);
end


function answer = missingTitle(fname)
% Return true if the specified demo is missing a title. 
text = getText(fname);
if startswith(strtrim(text{1}), '%%')
    answer = false; %not missing a title
elseif startswith(strtrim(text{1}), 'function')
    answer = ~startswith(strtrim(text{2}), '%%');
else
    answer = true;
end
end