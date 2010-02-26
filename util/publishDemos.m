function publishDemos()

cd(fullfile(pmtk3Root(), 'demos'));
d = dirs(); 
for i = 1:numel(d)
    publishFolder(d{i}); 
end





end