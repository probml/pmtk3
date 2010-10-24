function out = htmlTable(varargin)
% Display a Matlab cell array or numeric matrix as an html table
%
%PMTKauthor Gus Brown
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/18329
%PMTKmodified Matt Dunham 
%
% INPUTS:
%        'data'          the data to display, an array or cell array
%        'rowNames'      names for each row
%        'colNames'      names for each column
%        'title'         title for the table
%        'colormap'      matlab style colormap used to color the table see
%                         the colormap documentation for helper functions
%                         like hsv, summer(), etc. Only works for numeric
%                         arrays. See dataColors below for additional
%                         options.
%        'doshow'        [DEFAULT = true] if true, display the table in
%                         the Matlab web browser
%        'dosave'        [DEFAULT = false] if true, save the html table
%        'filename'      save to this file
%        'newWindow'     [DEFAULT = true] if true, a new window is opened.
%        'dataFormat'    a sprintf style formatter for the data
%        'rowFormat'     a sprintf sytle formatter for the row names
%        'colFormat'     a sprintf style formatter for the col names
%        'dataAlign'     [DEFAULT = 'center'] Options are ['left' |'right' | 'center']
%        'dataValign'    [DEFAULT = 'top'   ] Options are ['top','middle','bottom']
%        'bgColor'       [DEFAULT = 'white' ] background color: any valid html color spec
%        'borderColor'   [DEFAULT = 'grey'  ] color of the border: any%        valid html color spec
%        'cellPad'       [DEFAULT = 9] minimum cell padding applied
%        'vertCols'      [DEFAULT = false] if true, the column names, (if any) are displayed vertically.
%        'caption'       text displayed above or below the table
%        'captionLoc'    [DEFAULT = 'bottom'] Options are ['bottom' | 'top']
%        'captionFontSize
%        'dataColors'    a cell array of colors, the same size as data -
%                         if specified, each cell is colored according to the corresponding
%                         entry in dataColors.
%     'tableAlign'       
%     'tableValign'      
%     'colNameAlign'     
%     'colNameValign'    
%     'rowNameAlign'     
%     'rowNameValign'    
%     'rowNameColors'    
%     'colNameColors'    
%     'titleAlign'       
%     'titleValign'      
%     'titleFontSize'    
%     'dataFontSize'     
%     'rowNameFontSize'  
%     'colNameFontSize'  
%     'titleBarColor'    
%     'colSpan'          
%     'customCellAlign'  
%     'header'           
%
%
% OUTPUT: The html text as a char array, (only if nargout > 0)
%
% Notes:
%
% You can nest tables by specifying a table as one of the data cells as in
% htmlTable({{'one';{'two','three'}},1;2,3;4,'four'})
% You can nest as many levels as you like.

% This file is from pmtk3.googlecode.com


if iscell(varargin{1})
    varargin = insertFront('data', varargin);
end
[data          , rowNames      , colNames        , title         , colormap        , doshow          , ...
    dosave        , filename      , newWindow       , dataFormat    , rowFormat       , colFormat       , ...
    dataAlign     , dataValign    , bgColor         , borderColor   , cellPad         , vertCols        , ...
    caption       , captionLoc    , captionFontSize , dataColors    , tableAlign      , tableValign     , ...
    colNameAlign  , colNameValign , rowNameAlign    , rowNameValign , rowNameColors   , colNameColors   , ...
    titleAlign    , titleValign   , titleFontSize   , dataFontSize  , rowNameFontSize , colNameFontSize , ...
    titleBarColor , colSpan       , customCellAlign , header        , ...
    ] = process_options(varargin,...
    'data'             , []       ,...
    'rowNames'          , {}       ,...
    'colNames'          , {}       ,...
    'title'             , ''       ,...
    'colormap'          , []       ,...
    'doshow'            , true     ,...
    'dosave'            , false    ,...
    'filename'         , ''       ,...
    'newWindow'         , true     ,...
    'dataFormat'       , ''       ,...
    'rowFormat'        , ''       ,...
    'colFormat'        , ''       ,...
    'dataAlign'        , 'left' ,...
    'dataValign'       , 'top'    ,...
    'bgColor'          , 'white'  ,...
    'borderColor'      , 'grey'   ,...
    'cellPad'          , 9        ,...
    'vertCols'          , false    ,...
    'caption'           , ''       ,...
    'captionLoc'       , 'bottom' ,...
    'captionFontSize'  , 4        ,...
    'dataColors'        , {}       ,...
    'tableAlign'       , 'left'   ,...
    'tableValign'      , 'top'    ,...
    'colNameAlign'     , 'center' ,...
    'colNameValign'    , 'top'    ,...
    'rowNameAlign'     , 'left'   ,...
    'rowNameValign'    , 'center' ,...
    'rowNameColors'     , {}       ,...
    'colNameColors'     , {}       ,...
    'titleAlign'       , 'center' ,...
    'titleValign'      , 'top'    ,...
    'titleFontSize'    , 3        ,...
    'dataFontSize'     , 3        ,...
    'rowNameFontSize'  , 3        ,...
    'colNameFontSize'  , 3        ,...
    'titleBarColor'     ,'white'   ,...
    'colSpan'           ,[]        ,...
    'customCellAlign'   ,{}        ,...
    'header'            , ''       );

%%
if vertCols && ~isempty(colNames)
    for i=1:numel(colNames)
        name = colNames{i};
        newname = '';
        for j=1:numel(name);
            newname = [newname,name(j),'<br>']; %#ok
        end
        colNames{i} = newname;
    end
end

nDataCols = size(data,2);
if isempty(colSpan)
    colSpan = zeros(size(data,1),1);
end

if ~isempty(title) && iscell(title)
    title = catString(title,' <br> ');
end

if ischar(dataColors), dataColors = {dataColors}; end
if numel(dataColors) == 1
    dataColors = repmat(dataColors,size(data));
end

if ischar(rowNameColors), rowNameColors = {rowNameColors};end
if numel(rowNameColors) == 1
    rowNameColors = repmat(rowNameColors,size(data,1),1);
end

if ischar(colNameColors), colNameColors = {colNameColors};end
if numel(colNameColors) == 1
    colNameColors = repmat(colNameColors,1,size(data,2));
end
if iscell(data)
    data(cellfun(@(c)isempty(c),data)) = {'&nbsp;'};
end

%%
HTML = header;
MATname = 'DATA';
if isnumeric(data),
    MATmax = max(data(:));
    MATmin = min(data(:));
    MATrange = MATmax - MATmin;
end
if ~isempty(colormap),
    if (~isnumeric(colormap) || size(colormap,2)~=3)
        warning('htmlTable:colormap','colormap must be [nx3] array');
        colormap = [];
    end;
end;

% resize data
szmat = size(data);
data = reshape(data,szmat(1),szmat(2),prod(szmat(3:end)));

% create filename
if ~isempty(title) && isempty(filename)
    filename = ['TABLE_' title '.html'];
elseif isempty(filename);
    filename = 'TABLE.html';
end;

% set default row format
if isempty(rowFormat) && ~isempty(rowNames)
    if (iscell(rowNames(1))),
        if ischar([rowNames{1}]),
            rowFormat = '%s';
        else
            rowFormat = '%g';
        end;
    else
        if length(rowNames(1))>1,
            rowFormat = '%s';
        else
            rowFormat = '%g';
        end;
    end;
end;
% set default column format
if isempty(colFormat) && ~isempty(colNames)
    if (iscell(colNames(1))),
        if ischar([colNames{1}]),
            colFormat = '%s';
        else
            colFormat = '%g';
        end;
    else
        if length(colNames(1))>1,
            colFormat = '%s';
        else
            colFormat = '%g';
        end;
    end;
end;
% set default data format
if isempty(dataFormat)
    if ischar(data(1)),
        dataFormat = '%s';
    else
        dataFormat = '%g';
    end;
end;


% number of columns to be displayed
if ~isempty(rowNames),
    % add a blank cell if row labels are present
    szcols = size(data,2)+1;
else
    szcols = size(data,2);
end;
% HTML table
HTML = [HTML sprintf('<TABLE BGCOLOR=%s ALIGN=%s CELLPADDING=%d VALIGN=%s <CAPTION ALIGN=%s><font size=%d>%s</font></CAPTION>',borderColor,tableAlign,cellPad,tableValign,captionLoc,captionFontSize,caption)];
HTML = [HTML sprintf('\n\n')];  
% Table title row
if ~isempty(title)
    HTML = [HTML sprintf('<TR><TH COLSPAN=%g ALIGN=%s VALIGN=%s BGCOLOR=%s><font size=%d>%s</font></TH></TR>',szcols,titleAlign,titleValign,titleBarColor,titleFontSize,title)];
    HTML = [HTML sprintf('\n\n')];
end

% cycle through pages
for ipage = 1:size(data,3),
    page = data(:,:,ipage);
    if (size(data,3) > 1),
        % display page line
        HTML = [HTML sprintf('<TR><TH COLSPAN=%g ALIGN=%s VALIGN=%s BGCOLOR=ivory>%s(:,:,%g)</TH></TR>',szcols,dataAlign,dataValign,MATname,ipage)]; %#ok
    HTML = [HTML sprintf('\n\n')];  
    end;
    % Column labels
    if ~isempty(colNames),
        HTML = [HTML sprintf('<TR>')];  %#ok
        if (~isempty(rowNames) && length(colNames)<=size(page,2)),
            HTML = [HTML sprintf('<TD></TD>')]; %#ok
            HTML = [HTML sprintf('\n\n')];  
        end;
        if (iscell(colNames)),
            for jj = 1:length(colNames),
                if ~isempty(colNameColors)
                    color = colNameColors{jj};
                else
                    color = bgColor;
                end
                HTML = [HTML sprintf(['<TH BGCOLOR=%s ALIGN=%s VALIGN=%s><font size=%d>' colFormat '</font></TH>'],color,colNameAlign,colNameValign,colNameFontSize,[colNames{jj}])]; %#ok
                HTML = [HTML sprintf('\n\n')];  
            end;
        else
            HTML = [HTML sprintf(['<TH BGCOLOR=%s ALIGN=%s VALIGN=%s><font size=%d>' colFormat '</font></TH>'],bgColor,colNameAlign,colNameValign,colNameFontSize,colNames)]; %#ok
        HTML = [HTML sprintf('\n\n')];  
        end;
        HTML = [HTML sprintf('</TR>\n')]; %#ok
        HTML = [HTML sprintf('\n\n')];  
    end;
    % format data rows
    for ii = 1:size(page,1),
        HTML = [HTML sprintf('<TR>\n')];  %#ok new row of data
        HTML = [HTML sprintf('\n\n')];  
        % add row label to line
        if ~isempty(rowNames),
            if ii<=length(rowNames),
                if (iscell(rowNames)),
                    if ~isempty(rowNameColors)
                        color = rowNameColors{ii};
                    else
                        color = bgColor;
                    end
                    
                    HTML = [HTML sprintf(['<TH BGCOLOR=%s ALIGN=%s VALIGN=%s ><font size=%d>' rowFormat '</font></TH>'],color,rowNameAlign,rowNameValign, rowNameFontSize,[rowNames{ii}])]; %#ok
                    HTML = [HTML sprintf('\n\n')];  
                else
                    HTML = [HTML sprintf(['<TH BGCOLOR=%s ALIGN=%s VALIGN=%s ><font size=%d>' rowFormat '</font></TH>'],bgColor,rowNameAlign,rowNameValign, rowNameFontSize,rowNames(ii))]; %#ok
                    HTML = [HTML sprintf('\n\n')];  
                end;
            else
              HTML = [HTML sprintf('<TH></TH>')];  %#ok empty row
              HTML = [HTML sprintf('\n\n')];  
            end;
        end;
        
        % add data
        if (iscell(page)), % if data is of type cell array
            for jj = 1:length({page{ii,:}}), % columns of data
                % Extract data if single element cell array
                if iscell(page{ii,jj}) && length(page{ii,jj})==1,
                    page{ii,jj} = page{ii,jj}{1};
                end;
                % process cell based of content type
                if iscell(page{ii,jj}) && length(page{ii,jj})>1,
                    % create a sub table
                    tFORMAT = '%s';             % format for sting
                    page{ii,jj} = htmlTable(page{ii,jj},'doshow',false);
                elseif ischar(page{ii,jj}),
                    tFORMAT = '%s';             % format for sting
                elseif length(page{ii,jj})>1,
                    % create a sub table
                    tFORMAT = '%s';             % format for sting
                    page{ii,jj} = htmlTable(page{ii,jj},'sdoshow',false);
                else
                    if isempty(dataFormat)
                        tFORMAT = '%g';
                    else
                        tFORMAT = dataFormat;         % use user format
                    end;
                end;
                if colSpan(ii) == jj
                    colspanText = sprintf('colspan = "%d"',nDataCols-jj+1);
                else
                    colspanText = '';
                end
                if ~isempty(customCellAlign) && ~isempty(customCellAlign{ii,jj})
                    currentAlign =  customCellAlign{ii,jj};
                else
                    currentAlign = dataAlign;
                end
                
                
                if ~colSpan(ii) || colSpan(ii) >= jj
                    if isempty(dataColors)
                        HTML = [HTML sprintf(['<TD %s BGCOLOR=%s ALIGN=%s VALIGN=%s><font size=%d>' tFORMAT  '</font></TD>'],colspanText,bgColor,currentAlign,dataValign,dataFontSize,page{ii,jj})]; %#ok add data cell
                    else
                        HTML = [HTML sprintf(['<TD %s BGCOLOR=%s ALIGN=%s VALIGN=%s><font size=%d>' tFORMAT  '</font></TD>'],colspanText,dataColors{ii,jj},currentAlign,dataValign,dataFontSize,page{ii,jj})]; %#ok add data cell
                    end
                    HTML = [HTML sprintf('\n\n')];
                end
            end;
        else  % if data is no a cell array
            if (~isempty(colormap) && isnumeric(data)),
                for icol = 1:size(page,2),
                    % color cells according to value
                    if isempty(dataColors)
                        color = dec2hex( floor(255*interp1((0:1/(size(colormap,1)-1):1),colormap,(page(ii,icol)-MATmin)/MATrange)) )';
                    else
                        color = dataColors{ii,icol};
                    end
                    HTML = [HTML sprintf(['<TD BGCOLOR=#%6s ALIGN=%s VALIGN=%s><font size=%d>' dataFormat  '</font></TD>'],color,dataAlign,dataValign,dataFontSize,page(ii,icol))]; %#ok
                    HTML = [HTML sprintf('\n\n')];
                end;
            else
                
                for icol = 1:size(page,2)
                    if isempty(dataColors)
                        color = bgColor;
                    else
                        color = dataColors{ii,icol};
                    end
                    HTML = [HTML sprintf(['<TD BGCOLOR=%s ALIGN=%s VALIGN=%s><font size=%d>' dataFormat  '</font></TD>'],color,dataAlign,dataValign,dataFontSize,page(ii,icol))]; %#ok
                    HTML = [HTML sprintf('\n\n')];
                end
            end;
        end;
        HTML = [HTML sprintf('\n</TR>')]; %#ok close data row
        HTML = [HTML sprintf('\n\n')];
    end;
end;
HTML = [HTML sprintf('</TABLE><br>')];  % close table
HTML = [HTML sprintf('\n\n')];

% Save to html file
if (dosave),
    FID = fopen(filename,'w');
    fprintf(FID,'%s',HTML);
    fclose(FID);
    disp(sprintf('HTML table saved to file <a href="%s">%s</a>',filename,filename)); %#ok
end

if nargout == 1 || nargout < 0
    out = HTML;     % output html code
end

% display in browser window
if (doshow),
    if (newWindow),
        web(['text://<html>' HTML '</html>'],'-new','-notoolbar');
    else
        web(['text://<html>' HTML '</html>'],'-notoolbar');
    end;
end;


%% Here is Gus Brown's original documentation
% GTHTMLtable - Generate an HTML page with a table of a matrix.
%
% function FName = <a href="matlab: doc GTHTMLtable">GTHTMLtable</a>({NAME},MAT,{FORMAT},{COLS,{COLFORMAT}},{ROWS,{ROWFORMAT}},{flag,{...}},'colormap',map);
%
% This is intended to be a simple way to display 2D or 3D table data
% with support for row and column labels. Most arguments are optional,
% except for the data to be tabulated. Format specifiers are strings
% using the standard <a href="matlab: help sprintf">printf</a> format style. Data must be a 2D table or
% cell array. Cell arrays can mix strings and numbers.
%
% NAME   : Title for table, must be a string {OPTIONAL}
% MAT    : matrix to be displayed. Can be a list.
% FORMAT : sprintf style format for MAT elements {OPTIONAL}
% COLS      : Column names for table {OPTIONAL}. List of strings or
%             vector of numbers. Not both.
% COLFORMAT : sprintf style format for column elements {OPTIONAL}
% ROWS      : Row names for table {OPTIONAL}. List of strings or
%             vector of numbers. Not both.
% ROWFORMAT : sprintf style format for row elements {OPTIONAL}
% 'show'    : Show output {OPTIONAL} will prevent saving of file
%             unless 'save' is specified.
% 'save'    : Save output to HTML file {OPTIONAL} if show is not
%             specified the save is default.
% 'new'     : Open a new window {DEFAULT}
% 'old'     : Do not open a new window {OPTIONAL}
% 'colormap': define colormap to color contents, must be followed
%             by a colormap such as generated by  <a href="matlab: help hsv">hsv(10)</a>
%
% Note: Labels can be either strings or numbers, not both, mixing
%       will cause strange behavior.
%       Specifying more row labels than rows will cause the row
%       labels to be truncated.
%       Specifying more column labels than columns will result in
%       empty columns.
%       Imaginary numbers are not supported.
%       The colormap option is only supported for numeric arrays.
%
% Example:
% % The simplest form
% <a href="matlab: GTHTMLtable(rand([3 5 2]),'show');">[try]</a> GTHTMLtable(rand([3 5 2]),'show');
% % Using a color map to color contents
% <a href="matlab: GTHTMLtable(rand([3 5 2]),'colormap',hsv(10)/2+0.5,'show');">[try]</a> GTHTMLtable(rand([3 5 2]),'colormap',hsv(10)/2+0.5,'show');
% % with column labels
% <a href="matlab: GTHTMLtable('Table name',[1:4; 10:10:40],{'one' 'two' 'three' 'four'},'show');">[try]</a> GTHTMLtable('Table name',[1:4; 10:10:40],{'one' 'two' 'three' 'four'},'show');
% % with row labels and format specifiers
% <a href="matlab: GTHTMLtable('Table name',[1:4; 10:10:40],'%5.3f',[1:4],'%2.2i',{'one' 'two'},'ROW %s','show','old');">[try]</a> GTHTMLtable('Table name',[1:4; 10:10:40],'%5.3f',[1:4],'%2.2i',{'one' 'two'},'ROW %s','show','old');
% % The output argument is the html code, if the save option is not specified.
% <a href="matlab: html = GTHTMLtable([1:4; 10:10:40],{'first' 'second' 'third' 'fourth'},[1 2],'show')">[try]</a> html = GTHTMLtable([1:4; 10:10:40],{'first' 'second' 'third' 'fourth'},[1 2],'show')
% % The output argument is the html filename, if the save option is specified.
% % Nested tables are supported inside cell arrays.
% <a href="matlab: fname = GTHTMLtable('x',{1 [2:3]' 'three' 'four'; 10 20 30 40; 'a' 'e' 'r' 'o'},{'first' 'second' 'third' 'fourth'},{'1' '2' 'three'},'show','save')">[try]</a> fname = GTHTMLtable('x',{1 [2:3]' 'three' 'four'; 10 20 30 40; 'a' 'e' 'r' 'o'},{'first' 'second' 'third' 'fourth'},{'1' '2' 'three'},'show','save')
%
end
