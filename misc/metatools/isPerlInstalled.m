function installed = isPerlInstalled()
% Check if perl is installed by trying to run a simple script
try
    answer = perl('checkPerl.pl'); 
    installed = str2num(answer); 
catch %#ok
    installed = false; 
end
end