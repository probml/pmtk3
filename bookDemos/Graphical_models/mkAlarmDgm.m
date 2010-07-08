function dgm = mkAlarmDgm()
%% Make the alarm DGM
loadData('alarmNetwork'); 
dgm = dgmCreate(alarmNetwork.G, alarmNetwork.CPT); 



end