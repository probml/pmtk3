function success = downloadFile(source, dest)
%% Download a file from the web
% Source is the full url of the file
% dest is the full destination file path, including filename



if isPerlInstalled()
    fetcher = which('fetchfile.pl');
    status = perl(fetcher, source, dest);
    success = ~isempty(status) && str2num(status);
else
    [f, success] = urlwrite(source, dest);
end






end