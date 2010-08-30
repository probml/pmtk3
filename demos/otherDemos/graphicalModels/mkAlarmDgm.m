function dgm = mkAlarmDgm(infEngine)
%% Make the alarm DGM

if nargin < 1, infEngine = 'jtree'; end

loadData('alarmNetwork'); 
dgm = dgmCreate(alarmNetwork.G, alarmNetwork.CPT, 'infEngine', infEngine); 



end