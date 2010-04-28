function W = sequenceLogo(P, varargin)
%SEQLOGO displays sequence logos for DNA and protein sequences
%
%   SEQLOGO(SEQS) displays the sequence logo for a set of aligned sequences,
%   SEQS. The logo graphically displays the sequence conservation at a
%   particular position in an alignment of sequences, SEQS, as measured in
%   bits. The maximum sequence conservation per site is log2(4) bits for
%   DNA/RNA and log2(20) bits for proteins. SEQS must be aligned and
%   in a cell array or a character array format.
%
%   W = SEQLOGO(SEQS) returns a cell array of a unique symbol list in
%   SEQS, and the information weight matrix used for graphically
%   displaying the logo.
%
%   W = SEQLOGO(...,'DISPLAYLOGO',TF) displays the sequence logo of
%   SEQS when TF is TRUE. The default is TRUE.
%
%   SEQLOGO(...,'ALPHABET',A) specifies that SEQS consists of nucleotides
%   ('NT') or amino acids ('AA'). The default is NT.
%
%   SEQLOGO(...,'STARTAT',STARTPOSITION) specifies the starting position
%   for the sites of interest in SEQS. The default starting position is 1.
%
%   SEQLOGO(...,'ENDAT',ENDPOSITION) specifies the position for the
%   sites of interest in SEQS. The default ending position is the maximum
%   length in SEQS.
% 
%   SEQLOGO(...,'SSCORRECTION',false) specifies not to apply the small
%   sample correction. When there are only a few sample sequences a
%   straightforward calculation tends to overestimate the conservation. By
%   default SEQLOGO compensates by applying an approximate correction based
%   on the number of sequences. This correction is negligible more than
%   50 sequences are used.
% 
%   SEQLOGO(P) displays a sequence logo for P, a sequence profile generated
%   by SEQPROFILE. P is a matrix of size [20 x seq Length] with the
%   frequency distribution of amino acids. For nucleotides, P is of size 
%   [4 x seq Length] and the DNA alphabet is assumed. P may have 21 (or 5)
%   rows if gaps were included, but SEQLOGO ignores gaps. The sequence
%   conservation is computed without small sample correction. When P
%   contains weighted profiles or symbols counts the profile columns are
%   normalized to the maximum column sum of the profile.
% 
%   Example:
% 
%       S = {'ATTATAGCAAACTA',...
%            'AACATGCCAAAGTA',...
%            'ATCATGCAAAAGGA'}
%       % Display the sequence logo of S
%       seqlogo(S)
%
%       % Note that the small sample correction prevents you from seeing
%       % columns with information equal to log2(4) = 2 bits, however you
%       % can also turn this adjustment off:
%       seqlogo(S,'sscorrection',false)
% 
%       % Amino acid sequences
%       S1 = {'LSGGQRQRVAIARALAL'; 
%             'LSGGEKQRVAIARALMN'; 
%             'LSGGQIQRVLLARALAA';
%             'LSGGERRRLEIACVLAL'; 
%             'FSGGEKKKNELWQMLAL'; 
%             'LSGGERRRLEIACVLAL'};
%       seqlogo(S1, 'alphabet', 'aa', 'startAt', 2, 'endAt', 10)
% 
%   Reference:
% 
%       Schneider, T.D., Stephens, R.M., "Sequence Logos: A New Way to
%       Display Consensus Sequences," Nucleic Acids Research, 18, pp.
%       6097-6100, 1990. 
% 
%   See also SEQCONSENSUS, SEQDISP, SEQPROFILE.

%   SEQLOGO(...,'TOFILE',FILENAME) saves the sequence logo in PNG format
%   to a file named FILENAME.png. If FILENAME has no extension, .png is
%   assumed.

%   Copyright 2003-2007 The MathWorks, Inc.
%   $Revision: 1.1.12.7 $  $Date: 2007/08/15 17:16:41 $

% Validate input data
if nargin < 1
    error('Bioinfo:seqlogo:NotEnoughInputs',...
        '%s requires at least 1 input arguments.',mfilename);
end

startPos = 1;
endPos = 1;
isAA = false;
NTFlag = false;
displayLogo = true;
nSymbols = 4; % number of symbols in alphabet for NT, 20 for AA 
fileName = []; % a default file name
fileExt = 'png';     % Image file extension
corrError = true;
aaSymbols = 'ARNDCQEGHILKMFPSTWYV';
ntSymbols = 'ACGT';
symbolList = char(ntSymbols(:));

if nargin > 1
    if rem(nargin,2)== 0
        error('Bioinfo:seqlogo:IncorrectNumberOfArguments',...
            'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'alphabet','startat','endat','displaylogo','tofile', 'sscorrection'};
    for j=1:2:nargin-2
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname, okargs,numel(pname))); 
        if isempty(k)
            error('Bioinfo:seqlogo:UnknownParameterName',...
                'Unknown parameter name: %s.',pname);
        elseif length(k)>1
            error('Bioinfo:seqlogo:AmbiguousParameterName',...
                'Ambiguous parameter name: %s.',pname);
        else
            switch(k)
                case 1  % alphabet
                    if strcmpi(pval,'aa') % If sequences are Amino Acid
                        isAA = true;
                        nSymbols = 20; % 20 amino acids
                        symbolList = char(aaSymbols(:));
                    elseif ~strcmpi(pval,'nt') % If sequences are nucleotides
                        warning('Bioinfo:seqlogo:UnknownAlphabet',...
                            'Cannot resolve alphabet type ''%s''. The results will be the default alphabet type nucleotides.',upper(pval));
                        NTFlag = true;
                    else
                        NTFlag = true;
                    end
                case 2  % start position
                    if ~isnumeric(pval) || ~isscalar(pval)
                        error('Bioinfo:seqlogo:StartAtNotSingleNumericValue',...
                            'STARTAT must be a numeric value.');
                    elseif (pval <= 0)
                        error('Bioinfo:seqlogo:invalidStartAtValue',...
                            'STARTAT must be greater than or equal to 1.');
                    else
                        startPos = pval;
                    end
                    
                case 3  % end position
                    if ~isnumeric(pval) || ~isscalar(pval)
                        error('Bioinfo:seqlogo:EndAtNotSingleNumericValue',...
                            'ENDAT must be a numeric value.');
                    elseif (pval <= 0)
                        error('Bioinfo:seqlogo:invalidEndAtValue',...
                            'ENDAT must be greater than or equal to 1.');
                    else
                        endPos = pval;
                    end
                case 4  % showlogo
                    displayLogo = opttf(pval);
                    if isempty(displayLogo)
                        error('Bioinfo:seqlogo:InputOptionNotLogical','%s must be a logical value, true or false.',...
                            upper(char(okargs(k))));
                    end
                case 5 % to file
                    fileName = pval;
                    idx = findstr(fileName,'.');
                    if( idx > 0)
                        if ~strcmpi(fileName(idx+1:end), fileExt)
                            warning('Bioinfo:seqlogo:WrongFileExtension',...
                                'The files are saved in ''%s'' format only. The file extension will be changed to ''%s''.',upper(fileExt), fileExt);
                            fileName = [fileName(1:idx), fileExt];
                        end
                    else
                        fileName = [fileName, '.',  fileExt]; %#ok
                    end
                case 6 % error correction
                    corrError = opttf(pval);
                    if isempty(corrError)
                        error('Bioinfo:seqlogo:InputOptionNotLogical','%s must be a logical value, true or false.',...
                            upper(char(okargs(k))));
                    end
            end % end of switch
        end
    end
end

%=============================================================
if isnumeric(P) %P has the profile
    if any(size(P,1)==[20 21])
        isAA=true;
        freqM = P(1:20, :);
        symbolList = char(aaSymbols(:));
    else
        isAA=false;
        if any(size(P,1)==[4 5])
            freqM=P(1:4, :);
        else
            error('Bioinfo:seqlogo:IncorrectProfile',...
                  ['Invalid sequence profile,',...
                  'it must have 20 or 21 rows for AA, or 4 or 5 rows for NT.'])
        end
    end
    % normalizing columns
    freqM = freqM./max(sum(freqM));
    corrError=false;
else % P has sequences that may include ambiguous symbols
    if iscell(P) || isfield(P,'Sequence')
        if isfield(P,'Sequence') % if struct put them in a cell
            P = {P(:).Sequence};
        end
        P = P(:);
        P = strrep(P,' ','-'); % padding spaces are not considered 'align' chars
        P = char(P); % now seqs must be a char array
    end

    if ~ischar(P)
        error('Bioinfo:seqlogo:IncorrectInputType',...
            'First input argument must be the sequence profile or a set of aligned sequences.')
    end
    seqs = upper(P);
    [numSeq, nPos] = size(seqs);
    
    % Create a profile count matrix  column: - positions
    % row:    - number of unique characters
    uniqueList = unique(seqs);
    
%    if ~isAA && ~isnt(uniqueList) && ~NTFlag
     if ~isAA && ~NTFlag
        warning('Bioinfo:seqlogo:AmbigiousSequenceAlphabet',...       
            ['The alphabet type of the input sequence may not be nucleotide.',...
              '\nResults being displayed as the default alphabet type nucleotides.',...  
             '\nIf sequence is amino acids please specify the alphabet type.']);
    end
    
    m = length(uniqueList);
    pcM = zeros(m, nPos);
    for i = 1:nPos
        for j = 1:m
            pcM(j,i) = sum(seqs(:,i) == uniqueList(j));
        end
    end
    
    % Compute the weight matrix used for graphically displaying the logo
    % Not considering wild card or gap YET, only for real symbols
    freqM = [];
    [symbolList, tmpIdx] = regexpi(uniqueList', '[A-Z]', 'match');
    symbolList = char(symbolList');

    if ~isempty(tmpIdx)
        for i = 1:length(tmpIdx)
            freqM(i, :) = pcM(tmpIdx(i),:);
        end
    end

    % The observed frequence of a symbol at a particular sequence position
    freqM = freqM/numSeq;
end

%===============================================================
%maxLen - the max sequence length in the set
maxLen = size(freqM, 2);

if endPos == 1
    endPos = maxLen;
end

% Check that startPos and endPos are not outside the seqs
if startPos > endPos
    error('Bioinfo:seqlogo:StartAtGreaterThanEndAt',...
        'STARTAT should not be greater than the end position %d.', endPos);
end

if endPos > maxLen
    error('Bioinfo:seqlogo:ExceedLimit',...
        'ENDAT must be equal or less than the sequence length %d.', maxLen)
end

% == Compute the weight matrix used for graphically displaying the logo.
% Not considering wild card or gap YET, only for real symbols
freqM = freqM(:, startPos:endPos);
wtM = freqM; 
if isAA
    nSymbols = 20;
end

S_before = log2(nSymbols);
freqM(freqM == 0) = 1; % log2(1) = 0

% The uncertainty after the input at each position
S_after = -sum(log2(freqM).*freqM, 1);

if corrError
    % The number of sequences correction factor
    e_corr = (nSymbols -1)/(2* log(2) * numSeq);
    R = S_before - (S_after + e_corr);
else
    R = S_before - S_after;
end


nPos = (endPos - startPos) + 1;
for i =1:nPos
    wtM(:, i) = wtM(:, i) * R(i);
end

if nargout == 1
     % Create the seqLogo cell array
    W = cell(1,2);
    W(1,1) = {symbolList};
    W(1,2) = {wtM};
end

if isAA
    [wtM, symbolList] = sortWeightOrder(wtM, symbolList);
end

% Display logo
if displayLogo
    wtM (wtM < 0) = 0;
    if ~isempty(fileName)  % Save a image file
        seqshowlogo(wtM, symbolList, isAA, startPos, fileName);
    else
        seqshowlogo(wtM, symbolList, isAA, startPos);
    end
end
end
%-------------------- Helper functions and callbacks ----------------%
function [p,s] = sortWeightOrder(weight, symbollist)
% Sort weight matrix by the sort of symbol list in ASCII direction order
% Here only needed for AA
[s, index] = sort(symbollist);
p=weight;
for i = 1:size(weight, 2)
    x=weight(:,i);
    p(:,i) = x(index);
end
end
%--------------------------------------------------------------------%
function seqshowlogo(varargin)
%SEQSHOWLOGO displays a Java seqlogo frame in a figure window
isAA = false;
seqType = 'NT';
filename = 'seqlogo.png'; %#ok!
saveLogo = false;%#ok!
wtMatrix = [];
symbols = [];
startPos = 1;

if nargin == 4 % Pass in weight Matrix, list of symbols and isAA
    wtMatrix = varargin{1};
    symbols = varargin{2};
    isAA = varargin{3};
    startPos = varargin{4}; 
elseif nargin == 5 % Pass in weight Matrix, list of symbols, isAA and filename
    saveLogo = true;%#ok!
    wtMatrix = varargin{1};
    symbols = varargin{2};
    isAA = varargin{3};
    startPos = varargin{4}; 
    filename = varargin{5};%#ok!
end

if isAA
    seqType = 'AA';
end

import com.mathworks.toolbox.bioinfo.sequence.*;
import com.mathworks.mwswing.MJScrollPane;
import java.awt.Dimension;
% Create the viewer
logoViewer = SequenceViewer(wtMatrix, symbols,startPos, seqType);
awtinvoke(logoViewer,'addSeqLogo()');
scrollpanel = MJScrollPane(logoViewer, MJScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,...
                              MJScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);

% Create a figure with the seqlogo panel on it and a uitoolbar
logoContainer = [];
hFigure = figure( ...
            'WindowStyle', 'normal',...
            'Resize', 'on', ...
            'Toolbar', 'none',...
            'NumberTitle','off',...
            'Tag', 'seqlogo',...
            'Name', 'Sequence Logo',...
            'HandleVisibility', 'Callback',...
            'visible', 'off',...
            'DeleteFcn', {@onLogoClosing, logoViewer, logoContainer});
        
initFigureTools(hFigure, logoViewer)

% Set the figure widow size to fit the scrollPane
d = awtinvoke(scrollpanel, 'getPreferredSize()');
pos = getpixelposition(hFigure);
pos(3) = d.getWidth;
pos(4) = d.getHeight;
setpixelposition(hFigure,pos);
[logoP, logoContainer] = javacomponent(scrollpanel, ...
    [0, 0, pos(3), pos(4)], hFigure);%#ok

set(logoContainer, 'units', 'normalized');
set(hFigure, 'visible', 'on')
end
%----------------------------------------------------------------------%
% % Using figure print function instead.
% % function printHandler(hsrc, event,logoViewer) %#ok
% % awtinvoke(logoViewer, 'logoPrint()');

%----------------------------------------------------------------------%
function saveHandler(hsrc, event, logoViewer) %#ok
awtinvoke(logoViewer, 'saveLogoDialog()')
end  
%----------------------------------------------------------------------%
function onLogoClosing(hfig, event, logoViewer, logoContainer)%#ok
if ~isempty(logoViewer)
    awtinvoke(logoViewer, 'cleanup()');
    delete(logoContainer);
end
end
%--------------------------------------------------------------------
function initFigureTools(fig, logoViewer)
% helper function to set figure menus and toolbar
oldSH = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on')

% Handle toolbar 
toolbarHandle = uitoolbar('parent', fig);
hSave = uitoolfactory(toolbarHandle, 'Standard.SaveFigure');
set(hSave,  'ClickedCallback', {@saveHandler, logoViewer}, 'tooltip', 'Export Logo Image');

hPrint = uitoolfactory(toolbarHandle, 'Standard.PrintFigure');
set(hPrint, 'tooltip', 'Print');

% delete figure menus not used
h1 = findall(fig,'Type','uimenu', 'Label','&Edit');
h2 = findall(fig,'Type','uimenu', 'Label','&View');
h3 = findall(fig,'Type','uimenu', 'Label','&Insert');
h4 = findall(fig,'Type','uimenu', 'Label','&Tools');
h5 = findall(fig,'Type','uimenu', 'Label','&Desktop');
delete([h1,h2,h3,h4, h5])

% Repair "File" menu
hw = findall(fig,'Type','uimenu', 'Label','&File');
hf = get(hw,'children'); %#ok
h1 = findall(hw,'Label','&Save');
h2 = findall(hw,'Label','Print Pre&view...');
h3 = findall(hw,'Label','&Print...');
h4 = findall(hw, 'Label', '&Close');
delete(setxor(hf,[h1,h2,h3, h4]))

set(h1, 'label', '&Export Logo Image...', 'Callback', {@saveHandler, logoViewer});
set(h1,'Separator','on')

% Repair "Help" menu
hw = findall(fig,'Type','uimenu','Label','&Help');
delete(get(hw,'children'));
uimenu(hw,'Label','Bioinformatics Toolbox Help','Position',1,'Callback',...
       'web([docroot ''/toolbox/bioinfo/bioinfo_product_page.html''])')
uimenu(hw,'Label','Demos','Position',2,'Separator','on',...
       'Callback','demo(''toolbox'',''bioinfo'')')   
tlbx = ver('bioinfo');
mailstr = ['web(''mailto:bioinfofeedback@mathworks.com?subject=',...
           'Feedback%20for%20SeqLogo%20in%20Bioinformatics',...
           '%20Toolbox%20',tlbx(1).Version,''')'];
uimenu(hw,'Label','Send Feedback','Position',3,'Separator','on',...
       'Callback',mailstr);

set(0,'ShowHiddenHandles',oldSH)

end
%%%%%%%

function tf = opttf(pval,okarg,mfile)
%OPTTF determines whether input options are true or false

% Copyright 2003-2007 The MathWorks, Inc.
% $Revision: 1.3.4.3 $   $Date: 2007/09/11 11:42:46 $


if islogical(pval)
    tf = all(pval);
    return
end
if isnumeric(pval)
    tf = all(pval~=0);
    return
end
if ischar(pval)
    truevals = {'true','yes','on','t'};
    k = any(strcmpi(pval,truevals));
    if k
        tf = true;
        return
    end
    falsevals = {'false','no','off','f'};
    k = any(strcmpi(pval,falsevals));
    if k
        tf = false;
        return
    end
end
if nargin == 1
    % return empty if unknown value
    tf = logical([]);
else
    okarg(1) = upper(okarg(1));
    xcptn = MException(sprintf('Bioinfo:%s:%sOptionNotLogical',mfile,okarg),...
        '%s must be a logical value, true or false.',...
        upper(okarg));
    xcptn.throwAsCaller;
end

end