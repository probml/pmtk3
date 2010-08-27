function pmtkPublish(file, varargin)
%% Just like builtin publish except for .m file html google link expansion
% i.e. for every foo.m found in the comments, if foo.m is part of the PMTK
% suite of google code repositories, it is replaced with its full html
% link. The html display name used is the file name itself. 
%%
text = getText(file); 
recycle on; % make sure deleting puts things in recycle bin
for i=1:numel(text)
   line = text{i}; 
   if ~startswith(strtrim(line), '%')
       continue; 
   end
   toks = tokenize(line, ' '); 
   ndx =  find(cellfun(@(c)endswith(strtrim(c), '.m'), toks)); 
   for j=1:numel(ndx)
       t = strtrim(toks{ndx}); 
       link = googleCodeLink(t, t, 'publish'); 
       if ~isempty(link)
          line = strrep(line, t, link);  
       end
   end
   text{i} = line; 
end
f = which(file); 
bak =  fullfile(fileparts(f), [fnameOnly(f), '.bak']); 
evalc('system(sprintf(''move /Y %s %s'', f, bak))'); 
writeText(text, f); 
publish(file, varargin{:}); 
pause(0.1); 
fclose all; 
evalc('system(sprintf(''move /Y %s %s'', bak, f))'); 
end