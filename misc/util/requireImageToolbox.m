function requireImageToolbox()
% Throw an error as the calling function if the image toolbox is installed
if ~statsToolboxInstalled
    E = MException('PMTK:imageToolboxRequired',...
        'Sorry this code requires the image toolbox');
    throwAsCaller(E);
end

end