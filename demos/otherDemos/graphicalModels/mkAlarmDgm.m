%% Make the alarm DGM
%
%%
function dgm = mkAlarmDgm(infEngine)
if nargin < 1, infEngine = 'jtree'; end

loadData('alarmNetwork'); 
dgm = dgmCreate(alarmNetwork.G, alarmNetwork.CPT, 'infEngine', infEngine); 



end