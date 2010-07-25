function F = pmlFigureInfo(includeEx, includeSol)
%% Parse every figure in PML
%
% F{i}(j) is a struct storing info on the jth figure in chapter i
%%
if nargin == 0
    includeEx  = false; 
    includeSol = false; 
end
B = pmlGrabBook(includeEx, includeSol); 
nchaps = numel(B); 
F = cell(nchaps, 1); 
for i=1:nchaps
   chText = B{i}; 
   if ~isempty(chText)
      Fc = parseChapterFigs(chText);  
      for j=1:numel(Fc)
         Fc(j).figNumTxt = sprintf('%d.%d', i, Fc(j).figNum);  
      end
      F{i} = Fc;
   end
end
end


function F = parseChapterFigs(chText)
%%
one    = '\addfig';
two    = '\addtwofigs';
three  = '\addthreefigs';
four   = '\addfourfigs';
five   = '\addfivefigs';
six    = '\addsixfigs';
tags   = {one, two, three, four, five, six}; 
counts = 4:9;
T = catString(chText, ' '); 
F = []; 
for i=1:numel(tags)
    ndx = strfind(T, tags{i}); 
    for j = 1:numel(ndx)
        k = ndx(j); 
        n = counts(i); 
        nfigs = n-3; % -3 for {options}{caption}{label}
        Fk = parseSingleFigure(grab(T(k:end), n), nfigs); 
        Fk.sortkey = k; 
        F = [F, Fk]; %#ok
    end
end
if isempty(F)
    return;
end
perm = sortidx([F.sortkey]);
F = F(perm); 
F = rmfield(F, 'sortkey'); 
for i=1:numel(F)
    F(i).figNum = i; 
end
end

function Fstruct = parseSingleFigure(T, nfigs)
%% Parse a single \add*fig(*) command
[command, i] = grab(T, 1);     T = T(i+1:end);
[caption, i] = grab(T, 1);     T = T(i+1:end);
[label, i]   = grab(T, 1);     T = T(i+1:end);
fnames = cell(nfigs, 1);
for j=1:nfigs
    [fnames{j}, i] = grab(T, 1);
    T = T(i+1:end);
end

options = strtrim(textBetween(command, '{', '}')); 
caption = strtrim(caption); 
label   = strtrim(label); 
fnames  = strtrim(fnames); 
caption = strtrim(caption(2:end-1)); 
label   = strtrim(label(2:(end-1))); 
fnames  = cellfuncell(@(c)c(2:end-1), fnames); 
fnames  = strtrim(fnames); 

ndx = strfind(caption, '\codename');
if ~isempty(ndx)
    codename = grab(caption(ndx(1):end), 1); 
    codename = textBetween(codename, '{', '}'); 
else
    codename = '';
end
Fstruct = structure(options, caption, label, fnames, codename);
end

function [T, i] = grab(T, n)
%% Keep grabbing chars from T until curly braces have opened and closed n
%% times. 
lc = 0;
rc = 0; 
eqt = 0; 
i = 1; 
while i < length(T)
    if T(i) == '{'
        lc = lc+1;
    elseif T(i) == '}'
        rc = rc+1;
    end
    if lc > 0 && (lc == rc) 
       lc = 0;
       rc = 0;
       eqt = eqt+1;
    end
    if eqt == n
        break;
    end
    i = i+1; 
end
T = T(1:i); 
end

