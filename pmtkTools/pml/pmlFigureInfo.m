function F = pmlFigureInfo(includeEx, includeSol)
%% Parse every figure in PML
%
% F{i}(j) is a struct storing info on the jth figure in chapter i
%
% Each struct has these fields:
%
% options   - the options used with the figure, e.g. 'height=1.5in'
% caption   - the full raw caption text, (as one line)
% label     - the figure label used
% fnames    - the names of the source pdf files (a cell array)
% figNum    - the figure number relative to the chapter
% figNumTxt - the absolute figure number as a string, e.g. '12.2' 
% codeNames - all names appearing in calls to \codename{foo} in the caption
% macros    - a struct of additional macros, e.g. figcredit
%
% To combine figures from all chapters into one structured array use
% F = [F{:}]; 
%
%%

% This file is from pmtk3.googlecode.com

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
         Fc(j).chapter = i;
         Fc(j).figNumTxt = sprintf('%d.%d', i, Fc(j).figNum);  
      end
      F{i} = Fc;
   end
end
end

function F = parseChapterFigs(chText)
%% Extract all \add*fig(s) text from a chapter
one    = '\addfig';
two    = '\addtwofigs';
three  = '\addthreefigs';
four   = '\addfourfigs';
five   = '\addfivefigs';
six    = '\addsixfigs';
tags   = {one, two, three, four, five, six}; 
counts = 4:9; % number of args for each tag (macro)
%%
T = catString(chText, ' '); 
F = []; 
for i=1:numel(tags)
    ndx = strfind(T, tags{i}); 
    for j = 1:numel(ndx)
        k          = ndx(j); 
        n          = counts(i); 
        nfigs      = n-3; % -3 for {options}{caption}{label}
        Fk         = parseSingleFigure(grab(T(k:end), n), nfigs); 
        Fk.sortkey = k; 
        F          = [F, Fk]; %#ok
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
%% Parse a single \add*fig(s) command
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
fnames  = strtrim(cellfuncell(@(c)c(2:end-1), fnames)); 
%%

codeNames              = parseCaption(caption, '\codename'); 
macros.figtaken        = parseCaption(caption, '\figtaken'); 
macros.figcredit       = parseCaption(caption, '\figcredit');
macros.figthanks       = parseCaption(caption, '\figthanks');
macros.extfigcredit    = parseCaption(caption, '\extfigcredit');
macros.fignopermission = parseCaption(caption, '\fignopermission');
macros.figack          = parseCaption(caption, '\figack');

Fstruct = structure(options, caption, label, fnames, codeNames, macros);
end

function macroText =  parseCaption(caption, macro)
%% Parse a figure caption for the text in the first arg of a latex macro
% macroText is a cell array - one cell per occurrance of the macro
% Example: codeNames = parseCaption(caption, '\codename')
%%
ndx = strfind(caption, macro);
macroText = cell(numel(ndx), 1); 
for i=1:numel(ndx)
    macroText{i} = unwrapMacro(grab(caption(ndx(i):end), 1));
end    
end

function T = unwrapMacro(T)
%% Extracts the text 'foo' from \macro{foo}
T = T(find(T=='{', 1, 'first')+1:end-1);
end

function [T, i] = grab(T, n)
%% Keep grabbing chars from T until curly braces have opened and closed n times
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
