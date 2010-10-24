function requireImageToolbox()
% Throw an error as the calling function if the image toolbox is not installed

% This file is from pmtk3.googlecode.com

if ~imagesToolboxInstalled
    if isOctave()
        error('Sorry this code requires the MATLAB image toolbox'); 
    else
        E = MException('PMTK:imageToolboxRequired',...
            'Sorry this code requires the image toolbox');
        throwAsCaller(E);
    end
end

end
