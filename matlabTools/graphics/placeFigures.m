function varargout = placeFigures(varargin)
% Optimally lay out existing or new figures on the screen so that they
% don't overlap.
% 
% Figures are laid out from top to bottom and left to right (just like a
% Matlab matrix), and will have width and height greater than minwidth, &
% minheight, ([150,150] pixels by default). 
%
% To create new figure windows with this function, the 'newfigs' switch
% must be used. See the examples below. 
%
% NAMED PARAMETERS 
%
% nrows             (default = 2) The number of rows used in placing the
%                                 figures.
%
% ncols             (default = 3) The number of columns used in placing the
%                                 figures.
%
% depth             (default = 1)     The number of levels deep to display
%                                     figures. A setting of 2 for example
%                                     will 'double up' figures at each
%                                     location, one behind the other. 
%
% total             (default = nrows*ncols*depth) The number of figures in 
%                    total to display. Must be less than nrows*ncols*depth
%                    and greater than 1. Entries in the return value,
%                    handles, not corresponding to valid figure handles
%                    will be -1.
%
% square            (default = false) If false, figures take up as much
%                                     space as possible, both vertically 
%                                     and horizontally. If true, figures 
%                                     are forced to be square. 
%
% monitor           (default = 1)  If there is more than one monitor, 
%                   specify which monitor the figures should be displayed 
%                   on here. The main monitor is 1, the second monitor is 2
%                   (even if its 'to the left' of the main monitor).
%
% newfigs           (default = false) If true, new figures are created even
%                   if there are existing figures. Only the new figures are
%                   laid out optimally but you can execute a subsequent call
%                   to placeFigures() to lay them all out. If false, only
%                   existing figures are laid out. 
%
% SIZE SPECIFICATIONS (all measurements are in pixels)
%
% minwidth          (default = 150) A minimum width for a figure - must be 
%                                   greater than 108, Matlab's min size. 
%
% minheight         (default = 150) A minimum height for a figure, if
%                                   square = true, this must be > 108 too.
%
% intergapH         (default = 40)  The horizontal gap, between figures.
%
% intergapV         (default = 20)  The vertical gap, between figures.
%
% gapH              (default = 10)  The gap on the left and right side of
%                                   the screen.
%
% lowergap          (default = 50)  The gap at the bottom of the screen,
%                                   (need to make room for the start bar).
%
% uppergap          (default = 10)  The gap at the top of the screen.
%
% toolsize          (default = 50)  The size of each figure toolbar needs
%                                   to be accounted for separately. This is
%                                   an estimate of its height.
%
% RETURN VALUES
%
% handles                             A matrix of figure handles.
%                                     handles(n,m,r) returns the figure n
%                                     rows down, m cols over, and r levels
%                                     from the back. handles(k) returns the kth
%                                     figure to be displayed. Note by
%                                     default, r = 1 and so handles(m,n) is
%                                     sufficient. If total < nrows*ncols*depth,
%                                     the rest of the entries are -1.
%
% EXAMPLES:
%
% Suppose several figures have already been generated
% 
% placeFigures                                 - will layout the figures automatically
% placeFigures('nrows',1,'ncols',4)            - will layout the figures in 1 row,4 cols
% placeFigures('monitor',2)                    - will layout the figures on a second monitor
% placeFigures('square',false)                 - will not force figures to be square
% placeFigures('nrows',2,'ncols',2,'depth',2)  - will place figs 5-8 on top of figs 1-4
% h = placeFigures                             - returns the handles to the figures
% placeFigures('minwidth',250,'minheight',250) - increase minimum size of figures
% 
% - create new figures, even if figures already exist -
% placeFigures('newfigs',true,'total',9)       - create 9 new figures and lay them out
% placeFigures('newfigs',true,'nrows',3,...    - create 10 new figures in 3 rows & 4 cols
%                   'ncols',4,'total',10)
% 
% 
%%

% This file is from pmtk3.googlecode.com

                                                                                    
[nrows,ncols,depth,total,square,monitor,newfigs,minwidth,minheight,intergapH,...
intergapV,gapH,lowergap,uppergap,toolsize] = process_options(varargin,...
    'nrows'     ,'auto'    ,...
    'ncols'     ,'auto'    ,...
    'depth'     ,1         ,...
    'total'     ,'all'     ,...
    'square'    ,false      ,...
    'monitor'   ,1         ,...
    'newfigs'   ,false     ,...
    'minwidth'  ,150       ,...
    'minheight' ,150       ,...
    'intergapH' ,40        ,...
    'intergapV' ,20        ,...
    'gapH'      ,10        ,...
    'lowergap'  ,50        ,...
    'uppergap'  ,10        ,...
    'toolsize'  ,50        );
                                          
                                          
monitorSizes = getMonitorSizes(monitor);                                          
handles = setupVariables();               
[workingWidth,workingHeight] = getWorkingDimensions(monitor);
[figureWidth,figureHeight] = calcFigureSize(workingWidth,workingHeight,nrows,ncols);
[startH,startV] = calcStartLocation(monitor,nrows,figureHeight);
diffH =  figureWidth + intergapH;      
diffV = -figureHeight - intergapV;
if nargout ~= 0 
    varargout{1} = handles;
end
counter = 1;
for d=1:depth
    for col=1:ncols
        for row=1:nrows
            position = [startH+(col-1)*diffH,startV+(row-1)*diffV,figureWidth,figureHeight];
            figure(handles(counter));
            set(gcf,'Units','pixels','Position',position,'toolbar','none');
            counter = counter + 1;
            if(counter > total),return,end
        end
    end
end

    
    function handles = setupVariables()
    % Setup all of the variables, check if we are to lay out existing
    % figures and determine a layout, if not specified.
        uppergap = uppergap + toolsize;             
        intergapV = intergapV + toolsize;
        if(xor(strcmp('nrows','auto'),strcmp('ncols','auto')))
            error('nrows and ncols must be specified together or both left unspecified');
        end
        
        if(minwidth < 108 || (minheight < 108 && square))
           error('The minimum size you have specified is too small.'); 
        end

        existingHandles = allchild(0);
        existingHandles = existingHandles(end:-1:1);

        % There are 16 cases, (only 8 valid), depending on whether or not
        % there are existing handles, the value of newfigs, whether or not
        % nrows,ncols have been specified, and whether or not total has
        % been specified. We may end up with some redundant code here but
        % this way we can be sure to consider every case. 
        state = num2str(double([isempty(existingHandles),newfigs,strcmp(nrows,'auto'),strcmp(total,'all')]));
        switch state           
            case {'0  0  0  0' , '0  0  1  0'}
                error('You cannot specify a total when you want to display existing figures.');
            case {'1  0  0  0' , '1  0  0  1' , '1  0  1  0' , '1  0  1  1'} 
              error('There are no figures to place. Set ''newfigs'' to true to create blank figures.');
            case {'0  1  1  1', '1  1  1  1'}  
                error('You have to specify how many figures you want, either via ''nrows'',''ncols'', or ''total''');
            
            case '0  0  0  1'    % existing figs    , newfigs = false, layout specified   , total unspecified
                total = numel(existingHandles);
                if(nrows*ncols*depth < total)
                   error('Cannot fit all of the figures in this configuration.'); 
                end
                handles = -1*ones(nrows,ncols,depth);
                handles(1:total) = existingHandles;
            case '0  0  1  1'    % existing figs    , newfigs = false, layout unspecified , total unspecified
                total = numel(existingHandles);
                [nrows,ncols,depth] = bestLayout(total,square);
                handles = -1*ones(nrows,ncols,depth);
                handles(1:total) = existingHandles;
            case '0  1  0  0'    % existing figs    , newfigs = true , layout specified   , total specified
                if(total < 1 || total > nrows*ncols*depth);
                   error('Total is greater than nrows*ncols*depth or < 1'); 
                end
                start = max(existingHandles) + 1;
                handles = -1*ones(nrows,ncols,depth);
                handles(1:total) = start:start+total-1;
            case '0  1  1  0'    % existing figs    , newfigs = true , layout unspecified , total specified
                 [nrows,ncols,depth] = bestLayout(total,square);
                  start = max(existingHandles) + 1;
                 handles = -1*ones(nrows,ncols,depth);
                 handles(1:total) = start:start+total-1;
            case '0  1  0  1'    % existing figs    , newfigs = true , layout specified   , total unspecified
                total = nrows*ncols*depth;
                start = max(existingHandles) + 1;
                handles = -1*ones(nrows,ncols,depth);
                handles(1:total) = start:start+total-1;
            case '1  1  0  0'    % no existing figs , newfigs = true , layout specified   , total specified
                if(total < 1 || total > nrows*ncols*depth);
                   error('Total is greater than nrows*ncols*depth or < 1'); 
                end
                handles = -1*ones(nrows,ncols,depth);
                handles(1:total) = 1:total;
            case '1  1  0  1'    % no existing figs , newfigs = true , layout specified   , total unspecified
                total = nrows*ncols*depth;
                handles = -1*ones(nrows,ncols,depth);
                handles(1:total) = 1:total;
            case '1  1  1  0'    % no existing figs , newfigs = true , layout unspecified , total specified
                [nrows,ncols,depth] = bestLayout(total,square);
                handles = -1*ones(nrows,ncols,depth);
                handles(1:total) = 1:total;
        end
    end

    function [figureWidth,figureHeight] = calcFigureSize(workingWidth,workingHeight,nrows,ncols)
    % Calculate a new size for the figures. This may change global
    % variables lowergap and gapH.
        figureWidth  = fix((workingWidth - (ncols-1)*intergapH)/ncols);
        figureHeight = fix((workingHeight - (nrows-1)*intergapV)/nrows);
        if(figureWidth < minwidth || figureHeight < minheight)
            error('The figures will not all fit with this layout. Try letting placeFigures() do the layout automatically.');
        end
        if(square)
            [figureWidth,figureHeight] = makeSquare(figureWidth,figureHeight);
        end
    end

    function [figureWidth,figureHeight] = makeSquare(figureWidth,figureHeight)
    % Force figures to be square, altering the gapH and lowergap
    % margins to recenter. 
        if(figureHeight < figureWidth)
            diff = figureWidth - figureHeight;
            figureWidth = figureHeight;
            if(figureWidth < minwidth)
                diff = diff - (minwidth - figureWidth);
                figureWidth = minwidth;
            end
            gapH = ceil(gapH + 0.5*diff*ncols);
        end
        if(figureWidth < figureHeight)
            diff = figureHeight - figureWidth;
            figureHeight = figureWidth;
            lowergap = lowergap + diff*nrows;
        end
    end

    
    function monitorSizes = getMonitorSizes(monitor)
    % Get all of the monitor sizes and check that the specified monitor is
    % valid. 
        set(0,'Units','pixels');
        monitorSizes = get(0,'MonitorPositions');  
        if(monitor > size(monitorSizes,1) || monitor < 1)
            error('INITFIGURES:NoSuchMonitor',['Can''t Find Monitor ',num2str(monitor)])
        end
    end


    function [startH,startV] = calcStartLocation(monitor,nrows,figureHeight)
    % calculate where the first figure should be placed.     
        startH = monitorSizes(monitor,1) + gapH;
        
        % While the very bottom is usually 1, when only one monitor is used
        % and the screen resolution hasn't been changed since Matlab was
        % loaded, we need to account for these other possibilities as well
        ssize = get(0,'ScreenSize');
        offset = 1-ssize(2);
        veryBottom = (monitorSizes(1,4) - monitorSizes(monitor,4)+1) + offset;
        
        % We start with the figure in the top left corner.
        startV = veryBottom + lowergap + (figureHeight+intergapV)*(nrows-1);
    end
    

    function [workingWidth,workingHeight] = getWorkingDimensions(monitor)
    % get the total width and height of the specified screen we have to
    % work with after we subtract the border gaps, i.e. gapH, lowergap,
    % uppergap.   
        totalWidth  = monitorSizes(monitor,3) - monitorSizes(monitor,1) + 1;
        totalHeight = monitorSizes(monitor,4) - monitorSizes(monitor,2) + 1;
        workingWidth = totalWidth - 2*gapH;
        workingHeight = totalHeight - lowergap - uppergap;
    end

    function [nrows,ncols,depth] = bestLayout(N,square)
    % Calculate the best layout for N figures given minimum figure
    % size, (and shape) restrictions.
         if(square)
             minimum = min(minwidth,minheight);
             minwidth = minimum;
             minheight = minimum;
         end
         [workingWidth,workingHeight] = getWorkingDimensions(monitor);
         maxcols = fix((workingWidth + intergapH) / (minwidth + intergapH));
         maxrows = fix((workingHeight + intergapV) / (minheight + intergapV));
         nrows = 1; ncols = 1; depth = 1;
         if(N == 1), return, end
         optimalCols = min(maxcols,3);
         optimalRows = min(maxrows,2);
         working = false;
         while(not(working))
             if(nrows < optimalRows)
                 nrows = nrows + 1;
             elseif(ncols < optimalCols)
                 ncols = ncols + 1;
             elseif(nrows < maxrows)
                 nrows = nrows + 1;
             elseif(ncols < maxcols)
                 ncols = ncols + 1;
             else
                 depth = depth + 1;
             end
             holds = nrows*ncols*depth;
             if(holds >= N)
                 working = true;
             end
         end
    end



    
    

end
