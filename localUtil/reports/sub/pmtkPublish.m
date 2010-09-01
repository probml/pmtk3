function pmtkPublish(file, varargin)
%% Just like builtin publish except for .m file html google link expansion
% i.e. for every foo.m found in the comments, if foo.m is part of the PMTK
% suite of google code repositories, it is replaced with its full html
% link. Similarly for foo.html.
% The display name used is the file name itself. 
%%
if nargin == 2 && isstruct(varargin{1}) && isfield(varargin{1}, 'outputDir')
    outputDir = varargin{1}.outputDir;
else
    outputDir = fullfile(fileparts(which(file)), 'html'); 
end

text = getText(file);
recycle on; % make sure deleting puts things in recycle bin


%%
latexExpand = false; % not a user setting - this gets toggled on and off automatically. 
for i=1:numel(text)
   line = text{i};
   
   if ~startswith(strtrim(line), '%')
       continue; 
   end
   
   if isSubstring('<html>', line)
       latexExpand = true; 
   elseif isSubstring('</html>', line)
       latexExpand = false; 
   end
   
   
   %% mfile exapnsion
   toks = tokenize(line, ' ');
   ndxM =  find(cellfun(@(c)endswith(strtrim(c), '.m'), toks)); 
   ndxH =  find(cellfun(@(c)endswith(strtrim(c), '.html'), toks));
   ndx = [ndxM ndxH];
   for j=1:numel(ndx)
       t = strtrim(toks{ndx(j)}); 
       link = googleCodeLink(t, t, 'publish'); 
       if ~isempty(link)
          line = strrep(line, t, link);  
       end
   end
   if latexExpand
       %% latex expansions
       toks = unSandwich(line, '$', '$');
       for j=1:numel(toks)
           t = toks{j};
           htmlLink = texifyFormula(strtrim(t), genvarname(t), outputDir);
           line = strrep(line, ['$', t, '$'], htmlLink);
       end
   end
   text{i} = line; 
end
f = which(file);
bak =  fullfile(fileparts(f), [fnameOnly(f), '.bak']);
evalc('system(sprintf(''move /Y %s %s'', f, bak))'); 
writeText(text, f);
if isempty(varargin)
  opts.maxHeight = 300; opts.maxWidth = 300;
  publish(file, opts);
else
  publish(file, varargin{:});
end
pause(0.1); 
fclose all; 
evalc('system(sprintf(''move /Y %s %s'', bak, f))'); 
end