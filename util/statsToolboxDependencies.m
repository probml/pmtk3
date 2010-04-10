function statsToolboxDependencies
% Generate an html table showing all of the stats toolbox functions used
% by PMTK3 along with the PMTK3 functions that directly use them. 
cd(pmtk3Root());
R = deptoolbox('stats');
S = unique(vertcat(R.dependsOn{:}));
F = cell(numel(S), 1);
for i=1:numel(S)
    statsFn = S{i};
    for j=1:numel(R.filename)
        if ismember(statsFn, R.dependsOn{j})
            F{i} = insertEnd(R.filename{j}, F{i});
        end
    end
end
S = cellfuncell(@(c)argout(2, @fileparts, c), S);
F = cellfuncell(@(c)unique(c'), F);
F = cellfunR(@(c)argout(2, @fileparts, c), F);
perm = sortidx(cellfun(@numel, F), 'descend');
S = S(perm);
F = F(perm);
htmlTable('data', [S, F], 'colNames', {'STATS', 'PMTK3'},'dataAlign', 'left');

end
