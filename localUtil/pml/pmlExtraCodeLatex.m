function text = pmlExtraCodeLatex()
% Generates the latex code for the extra demos

% This file is from pmtk3.googlecode.com

root = fullfile(pmtk3Root(), 'bookDemos');
cd(root); 
d = cellstr(ls()); 
d = filterCell(d, @(c)~startswith(c, '.'));
text = cell(2, 1);
for i=1:numel(d)
   cd(d{i}); 
   if exist('.\extra', 'file')
       text = insertEnd('', text); 
       text = insertEnd(['%%%  ',d{i}], text);
       text = insertEnd('', text);
       m = mfiles('.\extra', 'removeExt', true);
       for j =1:numel(m)
          text = insertEnd(sprintf('\\extraCode{%s}{}', m{j}), text); 
       end
   end
   cd(root);    
end
writeText(text, 'C:\users\matt\Desktop\extraCode.txt'); 
end
