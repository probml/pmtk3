%% Make the alarm DGM
%
%%

% This file is from pmtk3.googlecode.com

function dgm = mkAlarmDgm(infEngine)
if nargin < 1, infEngine = 'jtree'; end

loadData('alarmNetwork'); 
dgm = dgmCreate(alarmNetwork.G, alarmNetwork.CPT, 'infEngine', infEngine); 



end
