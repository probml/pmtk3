function compiler = mexcompiler
% mexcompiler returns the name of the compiler used by mex.

% Written by Tom Minka

mexopts = fullfile(prefdir,'mexopts.bat');
if ~exist(mexopts,'file')
  compiler = '';
  return
end
fid = fopen(mexopts);
while 1
  txt = fgetl(fid);
  if ~ischar(txt), break, end
  if strmatch('set COMPILER=',txt)
    compiler = txt(14:end);
    break
  end
end
fclose(fid);
