function renameFileExtToLower(folder)
% We sometimes need to convert foo.PDF to foo.pdf
% since unix is case sensitive, but windows and mac are not.

files = dirPMTK(folder);
for fi=1:numel(files)
  fname = files{fi};
  [pathstr, name, ext] = fileparts(fname); %#ok
  if isequal(lower(ext), ext), continue; end
  fnameNew = fullfile(folder, sprintf('%s%s', name, lower(ext)));
  cmd = sprintf('mv  %s %s', fullfile(folder, fname), fnameNew);
  disp(cmd)
  s=system(cmd)
end

end