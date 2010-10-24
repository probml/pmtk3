function requireBioinfoToolbox()
% Throw an error as the calling function if the bioinfo toolbox is not installed

% This file is from pmtk3.googlecode.com

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
