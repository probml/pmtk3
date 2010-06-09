function success = downloadFile(source, dest)
%% Download a file from the web
fetcher = which('fetchfile.pl'); 
status = perl(fetcher, source, dest);
success = ~isempty(status) && str2num(status);
end