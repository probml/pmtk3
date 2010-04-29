function R = missingTitleReport()
% Generate a list of PMTK3 demos that are missing titles.
demos = processExamples({}, {}, 0, false)';
R = filterCell(demos, @(f)isempty(help(f)));
end
