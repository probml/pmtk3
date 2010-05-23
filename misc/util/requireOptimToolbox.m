function requireOptimToolbox()
% Throw an error as the calling function if the optim toolbox is not installed
if ~optimToolboxInstalled
    if isOctave
        error('Sorry this code requires the MATLAB optimization toolbox');
    else
        E = MException('PMTK:optimToolboxRequired',...
            'Sorry this code requires the optimization toolbox');
        throwAsCaller(E);
    end
end

end