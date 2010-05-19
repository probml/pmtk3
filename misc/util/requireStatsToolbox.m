function requireStatsToolbox()
% Throw an error as the calling function if the stats toolbox is not installed
if ~statsToolboxInstalled
    E = MException('PMTK:statsToolboxRequired',...
        'Sorry this code requires the stats toolbox');
    throwAsCaller(E);
end

end