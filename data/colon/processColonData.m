function [X, y] = processColonData()
%% Parse I2000.html, and tissues.html for X and y
% See http://genomics-pubs.princeton.edu/oncology/affydata/index.html
% for a description of the data. 
%
% There are 62 x 2000-dimensional examples
% y = -1 indicates malignant tissue
% y = +1 indicates normal tissue
%
D = getText('I2000.html');
D = D(cellfun('length', D) > 100);
D = strtrim(D); 
toks = cellfuncell(@(c)tokenize(c, ' '), D);
toks = cellfuncell(@(c)c(4:end), toks);
for i=1:numel(toks)
   toks{i}{1} =  strrep(toks{i}{1}, 'size="2">', '');
   toks{i}{end} = strrep(toks{i}{end}, '</font>', ''); 
end
sz = numel(toks{1}); 
for i=1:numel(toks)
    for j=1:sz
       t = (toks{i}{j});  
       t = strrep(t, '</p>', ''); 
       t = str2double(t);  
       assert(~isnan(t)); 
       toks{i}{j} = t; 
    end
end
X = cell2mat(cellfuncell(@(c)horzcat(c{:}), toks))';
%%

ytxt = getText('tissues.html');
y = sign(cell2mat(cellfuncell(@(c)str2double(c), ytxt(10:end-4))));
save('colon', 'X', 'y'); 


end