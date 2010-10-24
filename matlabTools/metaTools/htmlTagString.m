function tagstr = htmlTagString(tags)
%% Generate the html tag string for the demo/ synopsis tables

% This file is from pmtk3.googlecode.com

tagstr = {};
if ismember('PMTKbroken'           , tags), tagstr = [tagstr, {'X'} ]; end
if ismember('PMTKneedsStatsToolbox', tags), tagstr = [tagstr, {'S'} ]; end
if ismember('PMTKneedsOptimToolbox', tags), tagstr = [tagstr, {'O'} ]; end
if ismember('PMTKneedsBioToolbox'  , tags), tagstr = [tagstr, {'B'} ]; end
if ismember('PMTKneedsMatlab'      , tags), tagstr = [tagstr, {'M'} ]; end
if ismember('PMTKinteractive'      , tags), tagstr = [tagstr, {'I'} ]; end
if ismember('PMTKslow'             , tags), tagstr = [tagstr, {'*'} ]; end
if ismember('PMTKreallySlow'       , tags), tagstr = [tagstr, {'**'}]; end
tagstr = catString(tagstr, ' ');
if isempty(tagstr), tagstr = '&nbsp;'; end
end
