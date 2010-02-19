function tf = signalToolboxInstalled()
% Returns true if the signal processing toolbox is installed. 
    tf = exist(fullfile(matlabroot, 'toolbox', 'signal'), 'file');
end