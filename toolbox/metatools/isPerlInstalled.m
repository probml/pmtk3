function installed = isPerlInstalled()
% Check if perl is installed by trying to run a simple script
try
    answer = perl(fullfile(pmtk3Root(), 'toolbox', 'metatools', 'checkPerl.pl')); 
    installed = str2num(answer); 
catch %#ok
    installed = false; 
end
end