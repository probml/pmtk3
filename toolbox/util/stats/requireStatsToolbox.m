function requireStatsToolbox()
% Throw an error as the calling function if the stats toolbox is not installed
if ~statsToolboxInstalled
    if isOctave
        error('Sorry this code requires the MATLAB stats toolbox'); 
    else
        E = MException('PMTK:statsToolboxRequired',...
            'Sorry this code requires the stats toolbox');
        throwAsCaller(E);
    end
end

end