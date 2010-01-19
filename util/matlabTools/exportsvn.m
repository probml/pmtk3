function exportsvn(source, dest)
% Export and zip up a local svn repository, (ignores .svn files).
%   SOURCE:  path to the root directory of the svn source
%   DEST:    path to destination including zip file name
%   EXAMPLE: exportsvn C:\pmtk3 C:\users\matt\Desktop\pmtk3.zip
    
    tmpfile = tempname();
    writeText({'.svn'}, tmpfile);
    tmpfolder = tempname();
    mkdir(tmpfolder);
    systemf('xcopy /E /Q /EXCLUDE:%s %s %s', tmpfile, source, tmpfolder);
    zip(dest, [tmpfolder,'\*'])
    systemf('rmdir /Q /S %s', tmpfolder); 
    delete(tmpfile)
    
end