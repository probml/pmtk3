function requireBioinfoToolbox()
% Throw an error as the calling function if the bioinfo toolbox is not installed
if ~bioinfoToolboxInstalled
    if isOctave()
        error('Sorry this code requires the MATLAB bioinfo toolbox'); 
    else
        E = MException('PMTK:bioinfoToolboxRequired',...
            'Sorry this code requires the bioinfo toolbox');
        throwAsCaller(E);
    end
end

end