function h=boxplot(varargin)
%BOXPLOT Displays box plots of multiple data samples.
%   BOXPLOT(X) produces a box plot of the data in X.  If X is a matrix there
%   is one box per column, and if X is a vector there is just one box. On
%   each box, the central mark is the median, the edges of the box are the
%   25th and 75th percentiles, the whiskers extend to the most extreme
%   datapoints the algorithm considers to be not outliers, and the outliers
%   are plotted individually.  
%   
%   BOXPLOT(X,G) specifies one or more grouping variables G, producing a
%   separate box for each set of X values sharing the same G value or
%   values.  Grouping variables must have one row per element of X, or one
%   row per column of X. Specify a single grouping variable in G by using a
%   vector, a character array, a cell array of strings, or a vector
%   categorical array; specify multiple grouping variables in G by using a
%   cell array of these variable types, such as {G1 G2 G3}, or by using a
%   matrix.  If multiple grouping variables are used, they must all be the
%   same length.  Groups that contain a NaN or an empty string ('') in a
%   grouping variable are omitted, and are not counted in the number of
%   groups considered by other parameters.
%
%   By default, character and string grouping variables are sorted in the
%   order they initially appear in the data, categorical grouping variables
%   are sorted by the order of their levels, and numeric grouping variables
%   are sorted in numeric order.  To control the order of the groups,
%   you can either use categorical variables in G and specify the order of
%   their levels, or use the 'positions' argument.
%
%   BOXPLOT(AX, X, ...) produces a box plot in axes with handle AX.
%   
%   BOXPLOT(..., 'PARAM1', val1, 'PARAM2', val2, ...) specifies optional
%   parameter name/value pairs.
%     'plotstyle'     'traditional' (default), or 'compact' to specify a
%                     box style designed for plots with many groups.  The
%                     plotstyle changes the defaults for some other
%                     parameters, as described below.
%
%     'boxstyle'      'outline' (default) to draw an unfilled box with
%                     dashed lines for whiskers, or 'filled' to draw a
%                     narrow filled box with solid lines for whiskers.
%     'colorgroup'    One or more grouping variables, of the same type as 
%                     permitted for G, specifying that the box color should
%                     change when the specified variables change.  Default
%                     is [] for no box color change.
%     'colors'        Colors for boxes, specified as a single color (such
%                     as 'r' or [1 0 0]) or multiple colors (such as 'rgbm'
%                     or a three-column matrix of RGB values).  The sequence
%                     is replicated or truncated as required, so for example
%                     'rb' gives boxes that alternate in color.  Default
%                     when no 'colorgroup' is specified is to use the same
%                     color scheme for all boxes.  Default with
%                     'colorgroup' is a modified hsv colormap. 
%     'datalim'       A two-element vector containing lower and upper limits,
%                     used by 'extrememode' to determine which points are
%                     extreme.  Default is [-Inf Inf].
%     'extrememode'   'clip' (default) to move data outside the 'datalim'
%                     limits to the limit, or 'compress' to distribute such
%                     points evenly in a region just outside the limit,
%                     retaining the relative order of the points.  A
%                     dotted line marks the limit if any points are outside
%                     it, and two gray lines mark the compression region if
%                     any points are compressed.  Values at +/-Inf can be
%                     clipped or compressed, but NaNs still do not appear
%                     on the plot.  Box notches are drawn to scale and may
%                     extend beyond the bounds if the median is inside the
%                     limit; they are not drawn if the median is outside
%                     the limits.  
%     'factordirection' 'data' (default) to arrange the factors with the
%                     first value next to the origin, 'list' to arrange the
%                     factors left-to-right if on the x axis or top-to-
%                     bottom if on the y axis, or 'auto' to use 'data' for
%                     numeric grouping variables and 'list' for strings.
%     'fullfactors'   'off' (default) to have one group for each unique row
%                     of G, or 'on' to create a group for each possible 
%                     combination of group variable values, including
%                     combinations that do not appear in the data.
%     'factorseparator' Specifies which factors should have their values 
%                     separated by a grid line.  The value may be 'auto' or
%                     a vector of grouping variable numbers.  For example,
%                     [1 2] adds a separator line when the first or second
%                     grouping variable changes value.  'auto' is [] for
%                     one grouping variable and [1] for two or more
%                     grouping variables. Default is [].
%     'factorgap'     Specifies an extra gap to leave between boxes when
%                     the corresponding grouping factor changes value,
%                     expressed as a percentage of the width of the plot.
%                     For example, with [3 1], the gap is 3% of the width
%                     of the plot between groups with different values of
%                     the first grouping variable, and 1% between groups
%                     with the same value of the first grouping variable
%                     but different values for the second.  'auto'
%                     specifies that BOXPLOT should choose a gap
%                     automatically.  Default is [].
%     'grouporder'    Order of groups for plotting, specified as a cell
%                     array of strings.  With multiple grouping variables,
%                     separate values within each string with a comma.
%                     Using categorical arrays as grouping variables is an
%                     easier way to control the order of the boxes.
%     'jitter'        Maximum distance D to displace outliers along the
%                     factor axis by a uniform random amount, in order to
%                     make duplicate points visible.  D = 1 makes the
%                     jitter regions just touch between the closest
%                     adjacent groups.  The default is 0.
%     'labels'        Character array, cell array of strings, or numeric
%                     vector of box labels.  May have one label per group
%                     or per X value.  Multiple label variables may be
%                     specified via a numeric matrix or a cell array
%                     containing any of these types.
%     'labelorientation' 'horizontal' (default) for horizontal labels, or
%                     'inline' to draw the labels vertically when
%                     'orientation' has its default 'vertical' value.
%     'labelverbosity'  'all' (default) to display every label, 'minor' to
%                     display a label for a factor only when that factor
%                     has a different value from the previous group, or
%                     'majorminor' to display a label for a factor when
%                     that factor or any factor major to it has a
%                     different value from the previous group.
%     'medianstyle'   'line' (default) to draw a line for the median, or
%                     'target' to draw a black dot inside a white circle.
%     'notch'         'on' to draw comparison intervals using notches
%                     ('plotstyle' is 'traditional) or triangular markers
%                     ('plotstyle' is 'compact'), 'marker' to draw them
%                     using triangular markers, or 'off' (default) to omit
%                     them.  Two medians are significantly different at the
%                     5% level if their intervals do not overlap.  The
%                     interval endpoints are the extremes of the notches or
%                     the centers of the triangular markers.  When the
%                     sample size is small, notches may extend beyond the
%                     end of the box.
%     'orientation'   'vertical' (default) to plot X on the y axis, or
%                     'horizontal' to plot X on the x axis.
%     'outliersize'   Size of marker used for outliers, in points.
%                     Default is 6.
%     'positions'     Box positions specified as a numeric vector with one
%                     entry per group or X value (default 1:NGROUPS when the
%                     number of groups is NGROUPS).
%     'symbol'        Symbol and color to use for outliers, using the same 
%                     values as the LineSpec parameter S in PLOT.  Default
%                     is 'r+'. If the symbol is omitted then the outliers
%                     are invisible; if the color is omitted then the
%                     outliers have the same color as their corresponding
%                     box.  Any line specification in S is ignored.
%     'whisker'       Maximum whisker length W.  Default is W=1.5.  Points
%                     are drawn as outliers if they are larger than
%                     Q3+W*(Q3-Q1) or smaller than Q1-W*(Q3-Q1), where Q1
%                     and Q3 are the 25th and 75th percentiles, respectively.
%                     The default value 1.5 corresponds to approximately +/-
%                     2.7 sigma and 99.3 coverage if the data are normally
%                     distributed.  The plotted whisker extends to the
%                     adjacent value, which is the most extreme data value
%                     that is not an outlier. Set 'whisker' to 0 to give no
%                     whiskers and to make every point outside of Q1 and Q3
%                     an outlier.
%     'widths'        A scalar or vector of box widths to use when the
%                     'boxstyle' is 'outline'.  The default is half of the
%                     minimum separation between boxes, which is .5 when
%                     the 'positions' argument takes its default value.
%                     The list of values is replicated or truncated as
%                     necessary.
%
%   When the 'plotstyle' parameter takes the value 'compact', then the
%   default values for other parameters are the following:
%       boxstyle - 'filled'            labelverbosity - 'majorminor'
%       factorgap - 'auto'             medianstyle - 'target'
%       factorseparator - 'auto'       outliersize - 4
%       jitter - 0.5                   symbol - 'o'
%       labelorientation - 'inline'        
%
%   You can see the data values and group names by using the data cursor
%   tool, available from the figure window.  The data cursor shows the
%   original values of any points affected by the 'datalim' parameter.  You
%   can label the specific group to which an outlier belongs using the gname
%   function.
%
%   To modify the properties of box components, use findobj using tags to
%   find their handles as in one of the examples below.  The tag names
%   depend on the plotstyle and are:
%
%      all styles:  'Box', 'Outliers'
%      traditional: 'Median', 'Upper Whisker', 'Lower Whisker',
%                   'Upper Adjacent Value', 'Lower Adjacent Value', 
%      compact:     'Whisker', 'MedianOuter', 'MedianInner'
%      when 'notch' is 'marker':
%                   'NotchLo', 'NotchHi'
%
%   Examples:
%      % Box plot of car gas mileage grouped by country
%      load carsmall
%      boxplot(MPG, Origin)
%      boxplot(MPG, Origin, 'sym','r*', 'colors',hsv(7))
%      boxplot(MPG, Origin, 'grouporder', ...
%                   {'France' 'Germany' 'Italy' 'Japan' 'Sweden' 'USA'})
%
%      % Plot by median gas mileage
%      [sortedMPG,sortedOrder] = sort(grpstats(MPG,Origin,@median));
%      pos(sortedOrder) = 1:6;
%      boxplot(MPG, Origin, 'positions', pos)
%
%      % Change some graphics properties
%      boxplot(chi2rnd(1,100,10)); % Generate box plot
%      h=findobj(gca,'tag','Outliers'); % Get handles for outlier lines.
%      set(h,'Marker','o'); % Change symbols for all the groups.
%      set(h(1),'MarkerEdgeColor','b'); % Change color for one group
%
%   See also ANOVA1, KRUSKALWALLIS, MULTCOMPARE.

%   Older syntax is still supported but deprecated.
%       BOXPLOT(X,NOTCH,SYM,VERT,WHIS)
%   The new syntax must be used for all parameters in order to access any
%   of the new parameters.
%
%   H = BOXPLOT(...) returns the handle H to the lines in the box plot.
%   H has one column per box, consisting of the handles for the various
%   parts of the box.  For the traditional plotstyle, the rows correspond
%   to: upper whisker, lower whisker, upper adjacent value, lower adjacent
%   value, box, median, and outliers. For the compact plotstyle, the rows
%   correspond to: whiskers, box, median outer, median inner, and outliers.
%   If median comparison intervals are indicated with markers, H will have
%   two more rows for notch lo and notch hi.  If medianstyle or boxstyle 
%   have been set explicitly, the meaning of the rows will adjust 
%   accordingly.

%   References
%   [1] McGill, R., Tukey, J.W., and Larsen, W.A. (1978) "Variations of
%       Boxplots", The American Statistician, 32:12-16.
%   [2] Velleman, P.F. and Hoaglin, D.C. (1981), Applications, Basics, and
%       Computing of Exploratory Data Analysis, Duxbury Press.
%   [3] Nelson, L.S., (1989) "Evaluating Overlapping Confidence
%       Intervals", Journal of Quality Technology, 21:140-141.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 2.15.4.40.2.1 $  $Date: 2009/12/30 14:09:19 $

% % Parse Arguments - Top Level
% Process internal test modes.
earlyReturn = false;
if nargin>0 && ischar(varargin{1})
    switch varargin{1}
        case 'test',
            h = unitTest(varargin);
            return;
        case 'test2',
            varargin(1)=[];
            earlyReturn = true;
    end
end

% Pull out all args in a standard form.  Some args will be further
% processed by straightenX. plottype is not returned, as it just sets
% defaults for other args.
[ax,x,g,notch,symbol,orientation,whisker,labels,labelverbosity, ...
    colors, colorgroup,widths,grouporder,positions, ...
    fullfactors,factorgap,factorseparator, extrememode,datalim,...
    jitter,medianstyle,boxstyle,outliersize,labelorientation,...
    factordirection] ...
    = parseArgs(varargin);

% If X is empty, create an empty plot and return.
if isempty(x)
    newplot(ax);
    if nargout>0
        h = [];
    end
    return;
end


% Standardize x and g.
% Make xDat a column vector of length xlen, and gDat a cell vector
% containing one or more numeric or cell vectors of length xlen.  origRow
% is created for labeling where points came from.  gExplicit is true if
% the optional g parameter was specified, and false if it was computed.
[xDat,gDat,origRow,xlen,gexplicit,origInd,origNumXCols] = straightenX(x,g);


% % Compute What To Plot - Top Level

% Assign each datapoint to a group, and also to a colorgroup and a
% position. If fullfactors is true, additional groups will be added for
% padding if there isn't data for every possible combination of grouping
% variable levels.  If a grouping variable contains a NaN or empty string
% value, the corresponding points will be lumped into group 0, ignored
% when assigning positions and colors, and omitted from the plot.
colorsExplicit = ~isempty(colors);
labelsExplicit = ~isempty(labels);
[groupIndexByPoint,groupVisibleByPoint,labelIndexByGroup,gLevelsByGroup,...
    userLabelsByGroup,positionValueByGroup,colorIndexByGroup,...
    numFlatGroups,numGroupVars] =...
    identifyGroups (gDat,grouporder,positions,colorgroup,...
    fullfactors,xlen,gexplicit,labels,colorsExplicit,origNumXCols);

% Sort x, first by group and then by x.  Retain index to map back to
% original ordering.  gStart and gEnd are column vectors of length
% numFlatGroups, indicating the start and end element for each group inside
% xSorted.
[xSorted,groupVisibleByPointSorted,gStart,gEnd,origRow,origInd] = ...
    sortX(xDat,groupIndexByPoint,groupVisibleByPoint,...
    origRow,origInd,numFlatGroups);

% Compute global min and max, and establish thresholds used for extreme
% outliers.
[extremeSettings,clipLinepos,clipLineprops,dataPlotLimits] = ...
    computeClippingZones...
    (xSorted,groupVisibleByPointSorted,gStart,gEnd,datalim,extrememode);

% Determine where each box part will live along the data axis.
% Choose values for box and whiskers, along with the corresponding indices
% into xSorted, and store them into datasets.  Each dataset is
% numFlatGroups long.  boxVal has the directly calculated values, while
% boxValPlot may have altered when applying the extrememode settings.
[boxVal,boxValPlot,boxIdx] = computeBoxLocation(xSorted,...
    gStart,gEnd,whisker,numFlatGroups,extrememode,extremeSettings,origRow);


% Determine where each box will be placed along the factor axis.  This will
% be affected by a user-specified positions argument, or by factorgap
% adding space for legibility.
% gPos is the center for each box along the factor axis.
% factorsepPos is a cell array of vectors, giving locations for each level
% of factor separator line requested
[gPos,factorsepPos] = computeBoxPosition(labelIndexByGroup,...
    positionValueByGroup,factorgap, numFlatGroups, numGroupVars);

% Compute the width for each box, and also a scalar for the tightest
% spacing.
% Unless width is specified in an input arg, set them to half the narrowest
% gap between boxes.
[gWidth,maxGuaranteedGap] = computeBoxWidth(gPos, widths,numFlatGroups);

% Determine where to draw box separator lines.
[factorsepLinepos, factorsepLineprops] = computeBoxSeparators...
    (factorseparator,factorsepPos,numGroupVars);

% Compute random numbers to be used for offsetting outlier points along the
% factor axis.
outlierjitter = computeOutlierJitter(boxIdx.outliers,jitter,numFlatGroups);
boxValPlot.outlierjitter = outlierjitter;

% Compute margins around the data in the axes.
axislims = computeAxesMargin(orientation,gPos,gWidth,dataPlotLimits,...
    boxValPlot);

% Select colors for each item in the box plot.
[cWhisker,cBox,cMedian,cOutlier,outlierSymbol] = ...
    computeColor(colors,colorIndexByGroup,symbol,medianstyle,boxstyle);

% Decide whether to reverse the direction of the factor axis.
factorAxisDir = computeFactorAxisDir(orientation,factordirection,...
    gDat,gexplicit,labelsExplicit);


% % Do Rendering - Top Level

ax = newplot(ax);

% Do a bit more computation here, for non-rendering stuff that needs a
% valid axes handle.  The axis handle is needed to measure the width of
% text. Determine the text and location for each factor label.
[labelDataLocation,labelPtsPosition,labelText,columnPtsPosition,...
    displayLabel] =...
    computeBoxLabel...
    (ax, gPos, gLevelsByGroup,userLabelsByGroup, labelIndexByGroup, ...
    labelverbosity,orientation,labelorientation,numFlatGroups,...
    numGroupVars);

if earlyReturn
    close(ancestor(ax,'figure'));
    h={boxIdx,boxVal,boxValPlot,gPos,gWidth,maxGuaranteedGap,...
        labelText,labelDataLocation,labelPtsPosition,...
        columnPtsPosition,displayLabel,axislims,orientation,...
        origRow,origInd,cWhisker,cBox,cMedian,cOutlier,...
        outlierSymbol,labelorientation,notch,medianstyle,...
        boxstyle,outliersize,clipLinepos,clipLineprops,...
        factorsepLinepos,factorsepLineprops};
    return
end

% Now we are really ready to do the rendering...

% Set axis limits, to establish the margin.
axis(ax,axislims);

% Possibly flip the axis direction.
setFactorDirection(ax,orientation,factorAxisDir);

% Display a box around axes.
set(ax,'Box','on');

% Create an hg group to hold all the hg objects.
axhg = hggroup('parent',ax);

% Draw the data clipping and factor gapping lines.
% Draw them first, as it matters least if they are obscured by other things
% on top.
hclip = renderClippingLines(axhg,clipLinepos,clipLineprops,orientation);

hfactorseps = renderFactorSeparatorLines(axhg, factorsepLinepos, ...
    factorsepLineprops, orientation);

% Draw the boxes and outliers.
[hdata,houtliers] = renderBoxes(axhg,gPos,maxGuaranteedGap,orientation,...
    boxValPlot,cWhisker,cBox,cMedian,cOutlier,outlierSymbol, ...
    notch,medianstyle,boxstyle,gWidth,outliersize);

% Draw the factor labels and set a callback.
hlabel = renderLabels (labelDataLocation,labelPtsPosition,labelText,...
    columnPtsPosition,axhg,orientation,labelorientation,...
    displayLabel);

% Store info for gname.
storeGnameInfo(ax,houtliers,origInd,boxIdx,numFlatGroups,xlen);

% Configure custom datatips for data cursor and set a callback.
storeDatatipInfo(axhg,hdata,houtliers,hclip,hfactorseps,boxVal,...
    boxValPlot,gPos,notch,numFlatGroups);

% Return the handles from boxplot only if the user requested them.
if nargout>0
    h = hdata;
end


end

% % Parse Arguments - Helper Functions
%----------------------------
% Calls the local function given by a string in arg 2 with any arguments
% given in args 3 and following.
function outargs = unitTest(inargs)
fh = str2func(inargs{2});
if nargin(fh) ~= length(inargs)-2
    error('stats:boxplot:InputArgNumMismatch',...
        'Wrong number of input args.');
end
outargs = cell(nargout(fh),1);
[outargs{:}] = feval(fh,inargs{3:end});
end

%----------------------------
% Parses the input argument list, and stores either the user-provided or
% the default value in each variable.  Where the user can choose several
% parameter values that mean the same thing, they are mapped into one.
function [ax,x,g,notch,symbol,orientation,whisker,labels,labelverbosity,...
    colors, colorgroup,widths,grouporder,positions, ...
    fullfactors,factorgap,factorseparator, extrememode,datalim,...
    jitter,medianstyle,boxstyle,outliersize,labelorientation,...
    factordirection] = parseArgs(inargs)

if isempty(inargs)
    error('stats:boxplot:NoArgs',...
        'BOXPLOT requires one or more parameters.');
end


% Select default values.
ax = [];
x = [];
g = [];
notch = 'off';
symbol = 'plotstyledefault';
orientation = 'vertical';
whisker = 1.5;
labels = {};
labelverbosity = 'plotstyledefault';
colors = [];
colorgroup = [];
widths = [];
grouporder = [];
positions = [];
fullfactors = 0;
factorgap = 'plotstyledefault';
factorseparator = 'plotstyledefault';
extrememode = 'clip';
datalim = [-inf,inf];
jitter = nan; %plotstyledefault
medianstyle = 'plotstyledefault';
boxstyle = 'plotstyledefault';
outliersize = nan; %plotstyledefault
labelorientation = 'plotstyledefault';
factordirection = 'data';
plotstyle = 'traditional';
% Extra args that alias to other args.
color = [];
label = [];


% Extract optional argument ax.
[ax,inargs] = axescheck(inargs{:});
if length(inargs)<1
    error('stats:boxplot:MissingXargument',...
        ['You have supplied an axis handle, ',...
        'but you also need to supply X']);
end


% Extract mandatory argument x.
% X might be a vector, matrix, or string.
% Perform no error checking on x, this will be done in straightenX.
x = inargs{1};
inargs(1) = [];


% Extract optional argument g.
% Perform no error checking on g, this will be done in straightenX.
if length(inargs)>=1
    gCandidate = inargs{1};
    % Rule out NOTCH value and parameter name.
    if ~isempty(gCandidate) && ~isequal(gCandidate,1) && ...
            ~isequal(gCandidate,0) && ...
            ~(ischar(gCandidate) && size(gCandidate,1)==1)
        g=gCandidate;
        inargs(1) = [];
    end
end


% Determine if we have parameter names or the old syntax.
if length(inargs)>=1
   if ischar(inargs{1})
      okargs =   {'notch' 'symbol' 'orientation' 'whisker' 'labels' ...
          'labelverbosity' 'colors' 'colorgroup' 'widths' 'grouporder' ...
          'positions' 'fullfactors' 'factorgap' 'factorseparator' ...
          'extrememode' 'datalim' 'jitter' 'medianstyle' 'boxstyle' ...
          'outliersize' 'labelorientation' 'plotstyle' ...
          'factordirection' 'color' 'label' };
      defaults = { notch   symbol   orientation   whisker   labels ...
          labelverbosity   colors   colorgroup    widths   grouporder ...
          positions   fullfactors   factorgap   factorseparator  ...
          extrememode   datalim   jitter   medianstyle   boxstyle  ...
          outliersize   labelorientation    plotstyle   ...
          factordirection    color   label};

      [eid,emsg,...
          notch,   symbol,   orientation,   whisker,   labels, ...
          labelverbosity,   colors,   colorgroup,    widths,   grouporder, ...
          positions,   fullfactors,   factorgap,   factorseparator,  ...
          extrememode,   datalim,   jitter,   medianstyle,   boxstyle,  ...
          outliersize,   labelorientation,  plotstyle,   ...
          factordirection    color   label] = ...
          internal.stats.getargs(okargs,defaults,inargs{:});
      if ~isempty(eid)
          error(sprintf( 'stats:boxplot:%s',eid),emsg);
      end
   else
       % Deprecated old-style calling convention.
       if (length(inargs)>=1) && ~isempty(inargs{1})
           notch = inargs{1}; end
       if (length(inargs)>=2) && ~isempty(inargs{2})
           symbol = inargs{2}; end
       if (length(inargs)>=3) && ~isempty(inargs{3})
           orientation = inargs{3}; end
       if (length(inargs)>=4) && ~isempty(inargs{4})
           whisker = inargs{4}; end
   end
end

% Convert inputs to standardized values.
% Standardize notch.
switch notch
    case {0,'off'}
        notch = 'off';
    case {1,'on'}
        notch = 'on';
    case {'marker'};
        notch = 'marker';
    otherwise
        if isempty(notch)
            notch = 'off';
        else
            error('stats:boxplot:BadNotch',...
                'Invalid value for ''notch'' parameter.');
        end
end


% Standardize orientation.
switch orientation
    case {0,'horizontal'}
        orientation = 'horizontal';
    case {1,'vertical'}
        orientation = 'vertical';
    otherwise
        % See if a partial match works.
        if ischar(orientation) && isvector(orientation) ...
                && ~isempty(orientation)
            orientationOptions = {'horizontal' 'vertical'};
            vert = strmatch(orientation,orientationOptions);
            if isempty(vert)
                error('stats:boxplot:BadOrientation',...
                    'Invalid value for ''orientation'' parameter.');
            end
            orientation=orientationOptions{vert};
        else
            error('stats:boxplot:BadOrientation',...
                'Invalid value for ''orientation'' parameter.');
        end
end

% Standardize whisker.
if ~isscalar(whisker) || ~isnumeric(whisker)
    error('stats:boxplot:BadWhisker',...
        'The ''whisker'' parameter value must be a numeric scalar.');
end


% Standardize labels.
% Accept 'label' in place of parameter name 'labels'.
if ~isempty(label)
    if isempty(labels)
        labels=label;
    else
        error('stats:boxplot:LabelLabelsDoubleAlias',...
            ['You cannot specify values for both ',...
            'Label and Labels parameters.']);
    end
end
% Check labels for invalid types.
if ~(isempty(labels) || iscellstr(labels) || ...
        (isnumeric(labels) && ndims(labels)==2) || ...
        (iscell(labels)&&ndims(labels)==2) || ...
        ischar(labels))
    error('stats:boxplot:BadLabelsType',...
        'Invalid value for ''labels'' parameter.');
end
% Convert labels to cell vector of vectors.
labels = convertToCellarrayOfColumnVectors(labels,'LABELS','string');
% There will be further checking on labels later, to ensure the correct
% length.

% Standardize extrememode.
switch (extrememode)
    case {'clip','compress'}
        %do nothing
    otherwise
        error('stats:boxplot:BadExtrememode',...
            'Invalid value for ''extrememode'' parameter.');
end

% Standardize datalim.

if ~isnumeric(datalim) || ~isvector(datalim) || numel(datalim)~=2 ...
        || datalim(1)>datalim(2) || any(isnan(datalim))
    error('stats:boxplot:BadDatalim',...
        'Invalid value for ''datalim'' parameter.');
end

% Standardize colors.
% Accept 'color' in place of parameter name 'colors'.
if ~isempty(color)
    if isempty(colors)
        colors=color; % Alias Color to Colors.
    else
        error('stats:boxplot:ColorColorsDoubleAlias',...
            ['You cannot specify values for both Color ',...
            'and Colors parameters.']);
    end
end
% Check that colors has valid values.
if isempty(colors)
    % Do nothing.
elseif ischar(colors)
    % Check that all color characters are valid.
    for i=1:numel(colors)
        [unusedStyle,unusedColor,unusedMarker,msg] = colstyle(colors(i));
        if ~isempty(msg)
            error('stats:boxplot:BadColorsChar',...
                ['Invalid value for ''colors'' parameter, character ',...
                'does not correspond to a valid color.']);
        end
    end
elseif isnumeric(colors)
    if ~(numel(colors)==3 || size(colors,2)==3)
        error('stats:boxplot:BadColorsNumericArg',...
            ['A numeric ''colors'' parameter must be a 3 element ',...
            'vector or a 3 column matrix']);
    end
else
    error('stats:boxplot:BadColorsArg',...
        ['The ''colors'' parameter must be a 3 element vector, a ',...
        '3 column matrix, a color character, or a string of ',...
        'color characters.']);
end


% Standardize colorgroup
% colorgroup should be empty, a cell vector with vectors of length
% numFlatGroups, or a cell vector with vectors of length xlen.  The
% vector lengths will be tested later.
colorgroup = convertToCellarrayOfColumnVectors(colorgroup,'COLORGROUP');

% Standardize widths.
if ~isempty(widths) && ...
    (~isvector(widths) || ~isnumeric(widths) || any(widths<=0) )
    error('stats:boxplot:BadWidths', ...
        ['The ''widths'' parameter value must ',...
        'be a numeric vector of positive values.']);
end
widths = widths(:);

% Standardize grouporder.
% Check grouporder for invalid types.
if ~(isempty(grouporder) || iscellstr(grouporder) || ischar(grouporder)) 
        error('stats:boxplot:BadOrderValue', ...
        ['The ''grouporder'' parameter value must be a character ',...
        'array or a cell array of strings.']);
end
% Convert grouporder to cell vector of vectors.
grouporder = convertToCellarrayOfColumnVectors...
    (grouporder,'GROUPORDER','string');
if length(grouporder)>1
    error('stats:boxplot:BadOrderValue', ...
        ['The ''grouporder'' parameter value must be a character ',...
        'array or a cell array of strings.']);
end
if ~isempty(grouporder)
    % Unpack grouporder, leave it as a cellstr vector.
    grouporder = grouporder{1};
end
    
% Standardize positions
% positions should be empty, a numeric vector of length numFlatGroups,
% or a numeric vector of length xlen.  The length will be tested later.
if ~isempty(positions) && ~isvector(positions)
    error('stats:boxplot:BadPosition',...
        '''positions'' parameter must be empty or a numeric vector.');
end
if ~isnumeric(positions)
    error('stats:boxplot:PositionsNumeric',...
        '''positions'' parameter must be numeric.')
end
positions=positions(:);

% Standardize fullfactors.
switch fullfactors
    case {0,'off','false'}
        fullfactors = false;
    case {1,'on','true'}
        fullfactors = true;
    otherwise
        error('stats:boxplot:BadFullfactors',...
            'Invalid value for ''fullfactors'' parameter.');
end


% Standardize factordirection.
if isempty(strmatch(factordirection,{'data','list','auto'},'exact'))
    error('stats:boxplot:BadFactordirection',...
        'Invalid value for ''factordirection'' parameter.');
end


% Standardize plotstyle.
switch plotstyle
    case {0,'traditional'}
        plotstyle = 'traditional';
    case {1,'compact'}
        plotstyle = 'compact';
    otherwise
        error('stats:boxplot:BadPlotStyle',...
            'Invalid value for ''plotstyle'' parameter.');
end


% Standardize symbol.
if strcmp(symbol,'plotstyledefault')
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', symbol = 'r+';
        case 'compact', symbol = 'o';
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''');
    end
end
[unusedLinestyle,unusedOutliercolor,unusedOutliermarkertype,msg] = ...
    colstyle(symbol);
if ~isempty(msg)
    error('stats:boxplot:BadSymbol',msg.message);
end


% Standardize labelverbosity.
if strcmp(labelverbosity,'plotstyledefault')
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', labelverbosity = 'all';
        case 'compact', labelverbosity = 'majorminor';
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''.');
    end
end
if isempty(strmatch(labelverbosity,{'all','minor','majorminor'},'exact'))
    error('stats:boxplot:BadLabelverbosity',...
        'Invalid value for ''labelverbosity'' parameter.');
end


% Standardize factorgap.
if strcmp(factorgap,'plotstyledefault')
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', factorgap = [];
        case 'compact', factorgap = 'auto';
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''.');
    end
end
if ~strcmp(factorgap,'auto') && ~(isvector(factorgap) && ...
        isnumeric(factorgap)) && ~isempty(factorgap)
    error('stats:boxplot:BadFactorgap',...
        'Invalid value for the ''factorgap'' parameter.');
end



% Standardize factorseparator.
if strcmp(factorseparator,'plotstyledefault')
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', factorseparator = [];
        case 'compact', factorseparator = 'auto';
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''.');
    end
end
if ~strcmp(factorseparator,'auto') && ...
        ~(isvector(factorseparator) && isnumeric(factorseparator) ) && ...
        ~isempty(factorseparator)
    error('stats:boxplot:BadFactorseparator',...
        'Invalid value for the ''factorseparator'' parameter.');
end


% Standardize jitter.
if isnan(jitter)
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', jitter = 0;
        case 'compact', jitter = .5;
        otherwise, error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''');
    end
end
if ~isscalar(jitter) || ~isnumeric(jitter)
    error('stats:boxplot:BadJitter',...
        'The ''jitter'' parameter value must be a numeric scalar.');
end

% Standardize medianstyle.
if strcmp(medianstyle,'plotstyledefault')
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', medianstyle = 'line';
        case 'compact', medianstyle = 'target';
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''.');
    end
end
switch medianstyle
    case {'line'}
        medianstyle = 'line';
    case {'target'};
        medianstyle = 'target';
    otherwise
        error('stats:boxplot:BadMedianStyle',...
            'Invalid value for the ''medianstyle'' parameter.');
end

% Standardize boxstyle.
if strcmp(boxstyle,'plotstyledefault')
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', boxstyle = 'outline';
        case 'compact', boxstyle = 'filled';
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''');
    end
end
switch boxstyle
    case {'outline'}
        boxstyle = 'outline';
    case {'filled'};
        boxstyle = 'filled';
    otherwise
        error('stats:boxplot:BadBoxStyle',...
            'Invalid value for the ''boxstyle'' parameter.');
end

% Standardize outliersize.
if isnan(outliersize)
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', outliersize = 6;
        case 'compact', outliersize = 4;
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''');
    end
end
if ~isnumeric(outliersize) || ~isscalar(outliersize)
    error('stats:boxplot:BadOutliersize',...
        'Invalid value for the ''outliersize'' parameter.');
end

% Standardize labelorientation.
if strcmp(labelorientation,'plotstyledefault')
    switch plotstyle % Default depends on plotstyle.
        case 'traditional', labelorientation = 'horizontal';
        case 'compact', labelorientation = 'inline';
        otherwise
            error('stats:boxplot:BadPlotStyle',...
                'Invalid internal value for ''plotstyle''');
    end
end
switch labelorientation
    case {'horizontal'}
        labelorientation = 'horizontal';
    case {'inline'};
        labelorientation = 'inline';
    otherwise
        error('stats:boxplot:BadLabelorientation',...
            'Invalid value for the ''labelorientation'' parameter.');
end


end

%----------------------------
% Standardize x and g.
% x can be a numeric vector or matrix.  It is guaranteed to be non-empty.
% g can be a numeric vector or matrix, categorical vector or matrix, char
%   array, cellstr, or a cell vector of vectors or cellstrs.  The vectors
%   should be the same length as x, if x is a column, or the same as the
%   number of columns in x if x is a matrix.
% Return xDat as a numeric column vector, with xlen rows.
% Return gDat as a non-empty cell vector of column vectors, each with
%   uniform length of xlen.  The column vectors are not necessarily
%   numeric.
% Return origRow, a column xlen long containing the row the observation
%   came from.
% Return xlen, the height of xDat.
% Return gexplicit, which is true if the g parameter is non-empty, due to
%   being specified by the user.

function [xDat,gDat,origRow,xlen,gexplicit,origInd,origNumXCols] =...
    straightenX(x,g)


if ~isnumeric(x) || ndims(x)>2
    error('stats:boxplot:XNumeric',...
        '''X'' parameter must be a numeric vector or matrix.');
end
[xRows,xCols] = size(x);

xDat = x(:);
xlen = numel(xDat);
origInd = (1:xlen)';
if xRows==1
    % If X is a vector, consider it to be a column vector.
    xRows = xlen;
    xCols = 1;
end
origNumXCols = xCols;

[gDat, gRows, gCols] = convertToCellarrayOfColumnVectors(g,'G');

if xCols==1
    % X is a vector.
    
    origRow = (1:xlen)';
    
    if gRows==0
        % Treat X as one big group, rather than xlen groups each with
        % one element.
        gexplicit = false;
        gDat = {ones(xlen,1)};
    else
        gexplicit = true;
        % If x was specified as a vector, gRows may be 1 or xlen.
        if ~(gRows==1 || gRows==xlen)
            error('stats:boxplot:XGLengthMismatch',...
                ['G must be the same length as X or ',...
                'the same length as the number of columns in X.']);
        end
        % If gDat has only 1 row, copy the one group repeatedly
        % to expand it to xlen rows.
        if gRows==1
            for i=1:gCols
                gDat{i} = gDat{i}(ones(xlen,1));
            end
        end
        
    end
    
else
    % When X is a matrix, convert it to a vector.  Each column of X will be
    % treated as a distinct group.
    
    [origRow,xMatgroup] = ind2sub([xRows,xCols],(1:xlen)');
    
    if gRows==0
        % If G absent, assign G according to X matrix column.
        gexplicit = false;
        gDat = {xMatgroup};
    else       
        % If G is present, it is required to have one element (for one
        % grouping variable in G) or row (for multiple grouping variables)
        % per column of X or per element of X.
        %
        % The number of columns in X will often be the same as
        % numFlatGroups, when it is calculated later, but it may differ
        % depending on the contents of G and the fullfactors parameter...
        % duplicates values and NaN/'' in G will reduce the eventual value
        % of numFlatGroups, while fullfactors will increase it if G
        % contains multiple grouping variables and does not contain every
        % possible combination of factor levels.
        
        gexplicit = true;
        if gRows==xlen
            % Do nothing.
        elseif gRows==xCols
            % Expand vectors in gDat to give them xlen rows.
            for i=1:gCols
                gDat{i} = gDat{i}(xMatgroup);
            end
        else
            error('stats:boxplot:XGLengthMismatch',...
                ['G must be the same length as X or ',...
                'the same length as the number of columns in X.']);
            
        end
    end
end




end

%----------------------------
% Standardize large args, and verify that lengths are self-consistent.
%
% Accepts argument in various forms:
% vector (numeric or categorical)
% matrix (numeric or categorical)
% cell vector of scalars or strings
% cell vector of vectors (vectors may be numeric, cellstrs, or categorical)
% character array
% empty
%
% Returns argument out in a standardized form:
% cell vector of equal-length column vectors
% out is empty if in is empty.

function [out,numrows,numcols] = ...
    convertToCellarrayOfColumnVectors(in,argname,outputType)

if nargin<3
    outputType = 'any';
end

if iscell(in) && ~isvector(in) && ~isempty(in)
    error('stats:boxplot:BadCellDataInput',...
        '''%s'' cell argument must be a vector',argname);
end

% Empty [] -> return empty.
if isempty(in)
    out = {};
    numcols = 0;
    numrows = 0;
    return;
end

% Convert in into a cell vector of cells or a cell with one vector.
if ~iscell(in)
    in = {in};
else
    
    % Elements must be all cells, all scalars, or all chars.
    if ischar(in{1}) && size(in{1},1)<=1 && isvector(in)
        % Check that we have a cell vector of chars.
        for i=2:length(in)
            if ~ischar(in{i}) || size(in{1},1)>1
                error('stats:boxplot:AllCellsAllScalars',...
                    '''%s'' cell argument must contain ',...
                    'all cells, all chars, or all scalars',argname);
            end
        end
        in = cellstr(in); % Create a cell vector with one cellstr.
        in = {in(:)};
    elseif isscalar(in{1}) && ~iscell(in{1}) && isvector(in)
        % Check that we have a cell vector of scalars.
        for i=2:length(in)
            if ~isscalar(in{i}) || iscell(in{i})
                error('stats:boxplot:AllCellsAllScalars',...
                    '''%s'' cell argument must contain all ',...
                    'cells, all chars, or all scalars',argname);
            end
        end
        tmp = in{1};
        for i=2:length(in)
            tmp(i) = in{i};
        end
        in = {tmp(:)};% Create cell with one vector.
    elseif iscell(in{1}) || ndims(in{1})==2
        % Check that we have a cell vector that contains cells, vectors, or
        % matrices.
        for i=2:length(in)
            if ~iscell(in{i}) && ndims(in{i})~=2
                error('stats:boxplot:AllCellsAllScalars',...
                    '''%s'' cell argument must contain ',...
                    'all cells, all chars, or all scalars',argname);
            end
            % Do nothing, we have a cell vector of cells.
        end
    end
end

% Create out from in, making it a row cell vector of column vectors.
% Initialize out, this may grow if in has matrix elements.
out = cell(1,length(in));
j = 1;
for i=1:length(in)
    % Unpack one level if needed.
    if isscalar(in{i}) && iscell(in{i}) && ~iscellstr(in{i})
        in{i}=in{i}{1};
    end
    if isvector(in{i}) && ~ischar(in{i})% Includes vector numeric and cellstr.
        out{j} = in{i}(:);
        j = j+1;
    elseif ischar(in{i}) % Char array, convert to cellstr.
        out{j} = cellstr(in{i});
        j = j+1;
    elseif ndims(in{i})==2 && ~iscell(in{i}) % Matrix, split up columns.
        for k=1:size(in{i},2)
            out{j} = in{i}(:,k);
            j = j+1;
        end
    else
        error('stats:boxplot:ArgInvalid',...
            '''%s'' contains an invalid value.',argname);
    end
end


numcols = size(out,2);
numrows = size(out{1},1);
% Test that all vectors are the same length.
for i=2:numcols
    if size(out{i},1)~=numrows
        error('stats:boxplot:UnequalLength',...
            'All columns in ''%s'' must have the same length.',argname);
    end
end

% Cast or complain about variable types.
switch outputType
    case 'numeric'
        for i=1:numcols
            if ~isnumeric(out{i})
                error('stats:boxplot:ArgNonNumeric',...
                    '''%s'' must be numeric.',argname);
                
            end
        end
    case 'string'
        for i=1:numcols
            if isnumeric(out{i})
                out{i} = cellstr(num2str(out{i}));
            end
        end
    case 'any'
        % Omit checking or casting.
    otherwise
        error('stats:boxplot:badOutputtype',...
            'Bad value for outputtype internal argument.');
end

end


% % Compute What To Plot - Helper Functions
%----------------------------

% Assign a group to each point, and assign a position, colorgroup, and
%   automatically generated label to each group.

% Input args:
% gDat is the standardized form of the input parameter g.  It is a
%   non-empty cell array of vectors, each of length xlen.
% grouporder is the input parameter, containing either a char array or a
%   cellstr vector, containing numFlatGroups strings.  It may also be
%   empty.
% positions is the input parameter, containing a numeric vector of length
%   0, numFlatGroups, or xlen.
% colorgroup is a processed version of the input parameter, containing a
%   cell vector of vectors, with the sub-vectors of uniform length and
%   either numFlatGroups or xlen long.  It may also be empty.
% fullfactors is the input parameter, a boolean.
% xlen is the number of data points.
% gexplicit is a boolean, indicating whether the user specified g
%   explicitly or whether one was generated automatically.
% labelsExplicit is a boolean, indicating whether the user specified
%   labels explicitly.
% colorsExplicit is a boolean, indicating whether the user specified
%   colors explicitly.

% Output args:
% groupIndexByPoint is a column vector of length xlen, containing an
%   integer between 0 and numFlatGroups, corresponding to the box a given
%   point is connected to.  Points with group 0 will not be plotted.  All
%   values from 1 through numFlatGroups will be present, unless fullfactors
%   is true AND gDat contains multiple grouping variables AND every
%   possible combination of grouping levels is not contained in the data.
% groupVisibleByPoint is column vector of length xlen, containing logical
%   true for points in a group that will plot.  Points in group 0 and
%   points in groups positioned at NaN are not plotted, and thus will be
%   false.
% labelIndexByGroup is a matrix with numFlatGroups rows, each row
%   corresponding to a box.  If labelsExplicit is true, then
%   labelIndexByGroup is a column vector, and the value selects the row
%   of strings to use in the labels argument. If labelsExplicit is false,
%   labelsIndexByGroup is a matrix with numGroupVars columns, and the
%   values correspond to the level of each group variable, used to index
%   into gLevels.
% gLevels is a vector cell array of length numGroupVars, with each
%   element a cellstr, containing the unique level names for the
%   corresponding grouping variable.  However, if labelsExplicit is true,
%   gLevels will be empty.
% positionValueByGroup is a column vector of length numFlatGroups,
%   giving the box center positions along the factor axis for each box.
% colorIndexByGroup is a column vector of length numFlatGroups,
%   giving an integer value for the assigned color group.  Or, it may be
%   empty to indicate the user specified no color information.
% numFlatGroups is the number of spots where they could be boxes or
%   labels.  If fullfactors is true, this may add to the number of
%   unique combinations of grouping variable levels, to give a spot for
%   every possible combination.  If gDat contains NaN's or empty strings,
%   those combination are not counted in numFlatGroups.
% numGroupVars is the number of grouping variables in gDat.

function [groupIndexByPoint,groupVisibleByPoint,labelIndexByGroup,...
    gLevelsByGroup,userLabelsByGroup,positionValueByGroup,...
    colorIndexByGroup,numFlatGroups,numGroupVars] =...
    identifyGroups (gDat,grouporder,positions,colorgroup,...
    fullfactors,xlen,gexplicit,labels,colorsExplicit,origNumXCols)

% Process gDat... assign each point to a group index, and generate
% automatic labels.  Groups that have NaN in one of the grouping variables
% will all be lumped into group index 0, and excluded from the
% numFlatGroups count and from the automatic labels.
[gLevelsByGroup,groupIndexByPoint,labelIndexByGroup,numFlatGroups,...
    numGroupVars] = ...
    assignInitialGroups(gDat,fullfactors,xlen);

% Values in grouporder refer to the automatically generated labels.
groupRemapGrouporder = applyGrouporder...
    (grouporder,gexplicit,fullfactors,gLevelsByGroup,...
    numFlatGroups,numGroupVars);

% Count how many groups have data.
if size(positions,1)==xlen || ...
        (~isempty(colorgroup) && size(colorgroup{1},1)==xlen) || ...
        (~isempty(labels) && size(labels{1},1)==xlen) 
    if fullfactors && numGroupVars>1
        % Groups may have been added by fullfactors, count how many
        % actually have data.
        groupsWithData = unique(groupIndexByPoint);
        numGroupsWithData = size(groupsWithData,1);
        % Don't count groups with nan or '' in grouping variable.
        if ~isempty(groupsWithData) && groupsWithData(1)==0
            numGroupsWithData = numGroupsWithData-1;
        end
    else
        numGroupsWithData = numFlatGroups;
    end
else
    % Don't bother counting if we are not going to use the value;
    numGroupsWithData = NaN;
end

% Assign positions to each datagroup.
% Reorder the groups if necessary so the positions are in sort
% order. Groups that are at positions=NaN are given the highest set of
% group numbers.
[positionValueByGroup,groupRemapPositions] = ...
    assignPositions(positions,groupIndexByPoint,numFlatGroups,xlen,...
    numGroupsWithData);

% Assign color to each datagroup.
% Do not drop groups that have NaN as part of their colorgroup.
colorIndexByGroup = assignColorgroups...
    (colorgroup,groupIndexByPoint,...
    numFlatGroups,xlen,numGroupsWithData);

% Assign user labels to each datagroup.
[userLabelsByGroup,numUserLabelVars,skipLabelGrouporderScramble] = ...
    assignUserLabels(labels,groupIndexByPoint,numFlatGroups,xlen,...
    numGroupsWithData);


% Combine all the scrambling and deletion into one mapping vector.
groupRemapCombined = layerGroupRemapping(0,...
    [groupRemapGrouporder,groupRemapPositions]);

% Scramble and renumber the groups based on groupRemapCombined.
% Don't affect those with group index 0.
validind = groupIndexByPoint>0; % validind is of type logical.
groupIndexByPoint(validind) = ...
    groupRemapCombined(groupIndexByPoint(validind));

% If colorgroup was specified by the user, scramble the color index to stay
% in sync with the data.  If colorgroup was not specified, choose the
% default value based on whether colors was specified by the user.
if ~isempty(colorIndexByGroup)
    colorIndexByGroup(groupRemapCombined) = colorIndexByGroup;
else
    % If colors parameter is explicitly specified by the user,
    % color the boxes in the order they appear on the axis.
    % If colors parameter was not specified, leave colorIndexByGroup
    % empty to assign all the boxes the default single color.
    if colorsExplicit
        colorIndexByGroup = (1:numFlatGroups)';
    end
end

% Compute and apply scramble to labels.  If labels were passed in
% explicitly by the user, then grouporder affects only the data and not
% the labels.
if numUserLabelVars>0
    if skipLabelGrouporderScramble
        groupRemapUserLabels = layerGroupRemapping(1,groupRemapPositions);
    else
        groupRemapUserLabels = layerGroupRemapping(1,...
            [groupRemapGrouporder,groupRemapPositions]);
    end
    for i=1:numUserLabelVars
        userLabelsByGroup{i} = userLabelsByGroup{i}(groupRemapUserLabels);
    end
end

% Scramble the previously computed labelIndexByGroup, to keep the
% automatic labels in gLevels in sync with the data.
groupRemapGLabels = layerGroupRemapping(1,...
    [groupRemapGrouporder,groupRemapPositions]);
labelIndexByGroup = labelIndexByGroup(groupRemapGLabels,:);
for i=1:numGroupVars
    gLevelsByGroup{i} = gLevelsByGroup{i}(groupRemapGLabels);
end

% Determine which groups will actually show up on the plot.
% Group 0 points have a NaN or '' in a grouping variable.
% Other groups may have been placed at position NaN or +/-Inf.
invisibleGroup = [0; find(~isfinite(positionValueByGroup))];
groupVisibleByPoint = ~ismember(groupIndexByPoint,invisibleGroup);


end

%----------------------------
% Layer multiple scrambling vectors into one that does the same thing.
% If requested, flip the sense of the vector to work on the opposite side
% of the assignment.
function [remapOut] = layerGroupRemapping(flip,remapIn)

[m,n] = size(remapIn);

% Layer the scrambling vectors.
remapOut = remapIn(:,1);
for i=2:n
    remapOut = remapIn(remapOut,i);
end

% Invert the sense of the indices if requested.
if flip
    remapOut(remapOut) = 1:m;
end

end

%----------------------------
% Compute flattened group numbers.
% gLevels is a cell array of cellstrs, one cellstr per grouping variable
%  whose length is the number of non-nan or non-blank levels in that
%  grouping variable.
% groupIndexByPoint is an xlen X 1 vector, containing the group number
%  for each point. If point has NaN in one of the grouping variables, set
%  its value in groupIndexByPoint to 0.  Groups with nan in one of the
%  grouping variables have no influence on gLevels, labelIndexByGroup, and
%  numFlatGroups.
% labelIndexByGroup is an numFlatGroups X numGroupVars matrix,
%  containing the level index of each grouping variable for each group.
% numFlatGroups is the number of individual groups of data destined for
%  plotting. There may be more than the actual number of groups of data if
%  fullfactors is true, numGroupVars>1, and the data does not contain every
%  possible combination of grouping variable levels.
% numGroupVars is the number of grouping variables in g.

function [gLevelsByGroup,groupIndexByPoint,labelIndexByGroup,...
    numFlatGroups,numGroupVars] = ...
    assignInitialGroups(gDat,fullfactors,xlen)

% Test gDat for correct length.  gDat already guaranteed to be non-empty,
% and to have vectors of equal length.
if length(gDat{1})~=xlen
    error('stats:boxplot:GroupVarMustMatchXLength',...
        ['Grouping variables must have the name number of ',...
        'elements as X, or, if X is a matrix, the same number of ',...
        'elements as there are columns in X.']);
end

% Convert each grouping variable into an index.
numGroupVars = length(gDat);
gMidx = zeros(xlen,numGroupVars);
gLevels = cell(1,numGroupVars);
groupLens = zeros(1,numGroupVars);
for i=1:numGroupVars
    [idx,levels] = grp2idx(gDat{i});
    numgroups = length(levels);
    gMidx(:,i) = idx;
    gLevels{i} = levels;
    groupLens(i) = numgroups;
end


if fullfactors==true
    % Leave space for boxes that have no data.
    colweight = fliplr(cumprod(fliplr(groupLens)));
    numFlatGroups = colweight(1);
    colweight = [colweight(2:end) 1];
    groupIndexByPoint = bsxfun(@times,gMidx-1,colweight);
    groupIndexByPoint = sum(groupIndexByPoint,2)+1;
    % Points with NaN in a grouping variable are assigned to group index 0.
    groupIndexByPoint(isnan(groupIndexByPoint)) = 0;
    labelIndexByGroup = fliplr(fullfact(fliplr(groupLens)));
else
    % Do not leave space for boxes that have no data.
    nonNanGroupByPoint = ~any(isnan(gMidx),2);
    [labelIndexByGroup,unused,groupIndex] = ...
        unique(gMidx(nonNanGroupByPoint,:),'rows');
    % Points with NaN in a grouping variable are assigned to group index 0.
    groupIndexByPoint = zeros(xlen,1);
    groupIndexByPoint(nonNanGroupByPoint) = groupIndex;
    numFlatGroups = size(labelIndexByGroup,1);
end

gLevelsByGroup = cell(1,numGroupVars);
for i=1:numGroupVars
    gLevelsByGroup{i} = gLevels{i}(labelIndexByGroup(:,i));
end

end

%----------------------------
% Process grouporder, compute the required scrambling.
function groupRemapGrouporder = applyGrouporder...
    (grouporder,gexplicit,fullfactors,gLevelsByGroup,...
    numFlatGroups,numGroupVars)

% If grouporder is specified, reorder the groups accordingly.
% Ignore grouporder unless g is specified explicitly.
if isempty(grouporder) || ~gexplicit
    groupRemapGrouporder = (1:numFlatGroups)';
else
    if  fullfactors==true
        error('stats:boxplot:GrouporderFullFactorConflict', ...
            ['The ''grouporder'' cannot be specified when the ',...
            '''fullfactors'' parameter is true. Consider using ',...
            'Categorical arrays to control the box order.']);
    end
    
    % Accept either newline or comma separators in grouporder.
    % Convert newlines in grouporder into commas.
    grouporder = strrep(grouporder,sprintf('\n'),',');
    % Append multiple automatic group names into one, comma separated.
    sep = ',';
    gLevelsByGroupSep(1:2:(numGroupVars-1)*2+1) = gLevelsByGroup;
    if numGroupVars>1
        gLevelsByGroupSep{2:2:(numGroupVars-1)*2} = sep;
    end
    gLevelsUniq = strcat(gLevelsByGroupSep{:});
    % Create mapping between user supplied grouporder and the ordering
    % generated so far.
    [groupUsed,groupRemapGrouporder] = ismember(gLevelsUniq,grouporder(:));
    
    % Grouporder must be a permutation of the group names.
    if any(groupUsed==0) || length(grouporder)~=numFlatGroups
        error('stats:boxplot:BadOrderUnique', ...
            ['Each unique group name in G must appear exactly once ',...
            'in the ''grouporder'' parameter.']);
    end
    
end
end



%----------------------------
% Accepts positions, which is a lightly processed version of the user input
%  parameter.  It is guaranteed to be a numeric column vector.  This
%  function will check that its length is appropriate - it must be empty,
%  numFlatGroups long, or xlen long.
% Returns positionValueByGroup, which is a numeric vector that is
%  numFlatGroups long.  The values will be in sorted order.
% Returns groupRemapPositions, which is numFlatGroups long.
%  The first element gives the new group number for what had been group 1,
%  the second for what had been group 2, etc, required to put the groups
%  into sorted order.  Groups with position NaN will be sorted to the
%  highest group numbers.
function [positionValueByGroup,groupRemapPositions] = ...
    assignPositions(positions,groupIndexByPoint,numFlatGroups,...
    xlen,numGroupsWithData)

% Process positions.
% If empty, set it to the default.  If length xlen, check that the points
%  in each box all have the same positions value. Set groupRemapPositions
%  to order the groups such that their positions are monotonically
%  increasing. Groups at position NaN are sorted to the end.  The groups at
%  non-NaN positions will be mapped to be contiguous from 1 to (number of
%  groups that have a non-NaN position).
switch size(positions,1)
    case 0,
        % A position is assigned regardless of whether a group has data.
        positionValueByGroup = (1:numFlatGroups)';
        groupRemapPositions = (1:numFlatGroups)';
    case numFlatGroups,
        % positionValueByGroup will contain NaN if the group is located at
        % position NaN.  If a group has no data (due to being added by
        % fullfactors), the position value remains what the user specified
        % rather than being set to NaN; even though there is no data, the
        % value will be used to place the labels.
        
        % Compute group remapping needed to put the positions into sorted
        % order.
        [positionValueByGroup,sortind] = sort(positions);
        
        % Invert the sense of the scrambling indices.
        groupRemapPositions = zeros(numFlatGroups,1);
        groupRemapPositions(sortind) = (1:numFlatGroups)';
        
    case xlen,
        groupValid = groupIndexByPoint~=0;
        
        uniquePositionsAndGroups = nanunique(...
            [positions(groupValid),groupIndexByPoint(groupValid)],...
            'rows','equalnans');
        
        % Check that no more than 1 position per group.
        % Note that it is ok to have more than one group per position.
        if size(uniquePositionsAndGroups,1)~=numGroupsWithData
            error('stats:boxplot:MultiplePositionsPerGroup',...
                ['Points with more than one value of ',...
                'the ''positions'' parameter are in the same group']);
        end
        
        if numGroupsWithData==numFlatGroups
            % fullfactors has not added any groups.
            positionValueByGroup = uniquePositionsAndGroups(:,1);
            groupRemapPositions = uniquePositionsAndGroups(:,2);
            
        else
            % fullfactors is on and has added groups, but we don't know
            % where to position them.  Position the added groups at NaN, so
            % things will look as if fullfactors is off.
            
            % Assign groups with data to their sorted positions.  Groups
            % with no data are at position NaN, sorted to the end.
            positionValueByGroup = nan(numFlatGroups,1);
            positionValueByGroup(1:numGroupsWithData) = ...
                uniquePositionsAndGroups(:,1);
            
            % Compute groupRemapPositions.
            % Find groupnums added by fullfactors.
            numAddedGroups = numFlatGroups-numGroupsWithData;
            addedGroups = setdiff(1:numFlatGroups,...
                uniquePositionsAndGroups(:,2));
            
            % Create map back to non-fullfactors groupnums.
            dataGroupsLogical = true(numFlatGroups,1);
            dataGroupsLogical(addedGroups) = false;
            fullToNonfullGroupRemap = cumsum(dataGroupsLogical);
            
            % Map groups with data to where they would have been without
            % fullfactors, and map groups without data to the groups at the
            % end. groupRemapPositions will have no 0 values.
            groupRemapPositions = zeros(numFlatGroups,1);
            groupRemapPositions(dataGroupsLogical) = ...
                fullToNonfullGroupRemap(uniquePositionsAndGroups(:,2));
            groupRemapPositions(addedGroups) = ...
                (numFlatGroups-numAddedGroups+1):numFlatGroups;
        end
        
    otherwise,
        error('stats:boxplot:BadPositionsLength',...
            ['''positions'' parameter must be empty, ',...
            'the same length as the number of groups, ',...
            'or the same length as the number of points']);
end

end




%----------------------------
% Process colorgroup.
% Convert colorgroup, which is a cell vector of equal-length vectors,
% into colorIndex, which is a vector of integers.
% If colorgroup is empty then pass it through, to get the default color
% indices.  If the user passed in a vector of integers for the colorgroup
% parameter, pass them through directly. Otherwise, map colorgroup to a
% single integer colorgroup number to each box.  NaN's in colorgroup are
% treated like any other number: they are sorted to the end of the color
% sequence, and do not make the box invisible. Values outside of 1:length
% of colormap will be wrapped later to the length of the colormap.

function colorIndexByGroup = assignColorgroups...
    (colorgroup,groupIndexByPoint,numFlatGroups,...
    xlen,numGroupsWithData)


if isempty(colorgroup)
    colorIndex = [];
else
    % We have one or more colorgroup vars, which may be of type cellstr,
    % double, or categorical.  They may be of length 0, numFlatGroups,
    % or xlen, but they are guaranteed to be all the same length.
    % Map into a single vector of ints of the same length as each
    % colorgroup var.
    
    numColorgroupVars = length(colorgroup);
    colorgroupLength = size(colorgroup{1},1);
    cMidx = zeros(colorgroupLength,numColorgroupVars);
    cGroupLens = zeros(1,numColorgroupVars);
    for i=1:numColorgroupVars
        [idx,unusedLevels] = grp2idx(colorgroup{i});
        numgroups = size(unusedLevels,1);
        cMidx(:,i) = idx;
        cGroupLens(i) = numgroups;
        % Treat NaN and empty values in colorgroup like any other,
        % assign them to the last index.
        cNans = isnan(cMidx(:,i));
        if any(cNans)
            cGroupLens(i) = cGroupLens(i)+1;
            cMidx(cNans,i) = cGroupLens(i);
        end
    end
    % Skip over color indices for colorgroup combinations that are not
    % used by the data. This makes the plot colors more consistent from one
    % set of data to the next.  To really ensure consistency, the user
    % should pass in categorical arrays for the colorgroup, to ensure all
    % possible level combinations are considered.
    colweight = fliplr(cumprod(fliplr(cGroupLens)));
    %    numColorGroups = colweight(1);
    colweight = [colweight(2:end) 1];
    colorIndex = bsxfun(@times,cMidx-1,colweight);
    colorIndex = sum(colorIndex,2)+1;
end

% Map colorIndex to colorIndexByGroup, based on the length of
% colorIndex.
switch size(colorIndex,1)
    case 0,
        colorIndexByGroup = [];
    case numFlatGroups,
        colorIndexByGroup = colorIndex;
    case xlen,
        groupValid = groupIndexByPoint~=0;
        
        uniqueGroupsAndColorgroups = unique(...
            [groupIndexByPoint(groupValid),colorIndex(groupValid)],...
            'rows');
        
        % Check that no more than 1 color per group.
        % Note that it is ok to have more than one group per color.
        % Points that have nan in a grouping variable (groupValid==false)
        % are not checked for color, as they will not be plotted.
        if size(uniqueGroupsAndColorgroups,1) ~= numGroupsWithData
            error('stats:boxplot:MultipleColorsPerGroup',...
                ['Points with more than one value of ',...
                'the ''colorgroup'' parameter are in the same group']);
        end
        
        if numGroupsWithData>0
            % Groups that are added by fullfactors will be set to the same
            % colorIndex as the first group.
            firstColorIndex = uniqueGroupsAndColorgroups(1,2);
            colorIndexByGroup = firstColorIndex*ones(numFlatGroups,1);
            colorIndexByGroup(uniqueGroupsAndColorgroups(:,1)) = ...
                uniqueGroupsAndColorgroups(:,2);
        else
            colorIndexByGroup = [];
        end
        
    otherwise,
        
        error('stats:boxplot:ColorgroupLengthMismatch',...
            ['Colorgroup variables must all be empty, ',...
            'the same length as the number of groups, or ',...
            'the same length as the number of data points in X.']);
end

end

%----------------------------
function [userLabelsByGroup,numUserLabelVars,...
    skipLabelGrouporderScramble] = assignUserLabels(labels,...
    groupIndexByPoint,numFlatGroups,xlen,numGroupsWithData)

numUserLabelVars = length(labels);
skipLabelGrouporderScramble = false;
if numUserLabelVars==0
    userLabelsByGroup = {};
else
    switch length(labels{1})
        case 0
            userLabelsByGroup = {};
            numUserLabelVars = 0;
        case numFlatGroups
            % Do not scramble the labels using grouporder, as the labels
            % are accepted in the same order that they are listed in
            % grouporder - the user already has applied the scrambling.
            skipLabelGrouporderScramble = true;
            userLabelsByGroup = labels;
        case xlen
            % Append multiple user labels variables into one.
            sep = ',';
            userLabelsByPointSep(1:2:(numUserLabelVars-1)*2+1) = labels;
            if numUserLabelVars>1
                userLabelsByPointSep{2:2:(numUserLabelVars-1)*2} = sep;
            end
            userLabelsByPoint = strcat(userLabelsByPointSep{:});       
            
            % Prepend group number.
            GroupsAndUserLabelsByPoint = strcat...
                (num2str(groupIndexByPoint),',',userLabelsByPoint);
            
            % Remove group 0 points, which we don't care about.
            groupValid = groupIndexByPoint~=0;
            GroupsAndUserLabelsByPoint(~groupValid) = [];
            
            [uniqueGroupsAndUserLabels,indI] = ...
                unique(GroupsAndUserLabelsByPoint);
            
            % Check that no more than 1 label per group.
            % Note that it is ok to have more than one group per label.
            % Points in group 0 are not checked for label, as they will 
            % not be plotted.
            if size(uniqueGroupsAndUserLabels,1) ~= numGroupsWithData
                error('stats:boxplot:MultipleLabelsPerGroup',...
                    ['Points with more than one value of ',...
                    'the ''labels'' parameter are in the same group.']);
            end
            
            userLabelsByGroup = cell(numUserLabelVars,1);
            if numGroupsWithData==numFlatGroups
                % Fullfactors has not added groups, copy labels over
                % directly.
                for i=1:numUserLabelVars
                    userLabelsByGroup{i} = labels{i}(indI);
                end
            else
                % Fullfactors has added groups, use '' to label those 
                % added groups.
                groupsWithDataLogical = false(numFlatGroups,1);
                groupsWithDataLogical(groupIndexByPoint(groupValid)) = ...
                    true;
                
                emptyLabel = {''};
                emptyLabel = emptyLabel(ones(numFlatGroups,1));
                for i=1:numUserLabelVars
                    reducedLabel = labels{i}(groupValid);
                    userLabelsByGroup{i} = emptyLabel;
                    userLabelsByGroup{i}(groupsWithDataLogical) = ...
                        reducedLabel(indI);
                end
            end
        otherwise
            error('stats:boxplot:BadLabels',...
                ['There must be the same number of labels as groups or ',...
                'as the number of elements in X.']);
    end
    
end

end

%----------------------------
% sortX first by group index and then by data.  In addition, create lookup
%  tables one can use to find the data for the group, as well as to map
%  back to the unsorted data location.
% gStart and gEnd are numFlatGroups long, and point to the contiguous
%  section of xSorted containing data from the group corresponding to the
%  row in gStart and gEnd.

function [xSorted,groupVisibleByPointSorted,gStart,gEnd,...
    origRow,origInd] = ...
    sortX(xDat,groupIndexByPoint,groupVisibleByPoint,...
    origRow,origInd,numFlatGroups)

[sorted,sortinds] = sortrows([groupIndexByPoint,xDat]);

gIndSorted = sorted(:,1);
xSorted = sorted(:,2);
origRow = origRow(sortinds);
origInd = origInd(sortinds);
groupVisibleByPointSorted = groupVisibleByPoint(sortinds);

% Create gStart and gEnd lookup tables, indicating the start and end of
% each group's data in xSorted.
fd = find(diff(gIndSorted));
% Add the first group, as long as the first group is not group 0.
% gIndSorted is guaranteed to be non-empty, as the main function bails
% out if x is empty.
if gIndSorted(1)~=0
    fd = [0; fd];
end
gStart = nan(numFlatGroups,1);
gEnd = gStart;
if ~isempty(fd)
    runlen = diff([fd;length(gIndSorted)])-1;
    groupsWithData = gIndSorted(1+fd);
    gStart(groupsWithData) = 1+fd;
    gEnd(groupsWithData) = 1+fd+runlen;
end

end

%----------------------------
% Choose the regions where extreme outliers could be put.
% extremeSettings is a structure defining the clipping bounds, and
%   the zones outliers will be compressed into.
% clipLinepos and clipLineprops define the location and linestyles of the
%   clipping lines.  Note that there will be no lines unless points get
%   clipped.
function [extremeSettings,clipLinepos,clipLineprops,dataPlotLimits] = ...
    computeClippingZones(xSorted,groupVisibleByPointSorted,...
    gStart,gEnd,datalim,extrememode)

% Compute global min and max.
globalmin = min(xSorted(groupVisibleByPointSorted));
if  ~isempty(globalmin) && ~isnan(globalmin)
    globalmax = max(xSorted(groupVisibleByPointSorted));
else
    % No data, setting limits that will not cause clipping lines.
    globalmin = datalim(1);
    globalmax = datalim(2);
end

% Compute the min and max that does not exceed the datalim's.
plotmin = max(datalim(1),globalmin);
plotmax = min(datalim(2),globalmax);
plotdatawidth = plotmax-plotmin;

switch extrememode
    case 'compress'
        % Leave a 5% gap between the nonextreme and the extreme data,
        % and compress the extreme data into a band that is 10% wide.
        margin = .05*plotdatawidth;
        compressdisplayzone = .1*plotdatawidth;
    case 'clip'
        % Pull in extreme data to the data limit.
        margin = 0;
        compressdisplayzone = 0;
    otherwise
        error('stats:boxplot:BadExtrememode',...
            'Bad value for ''extrememode'' parameter');
end

lomin = plotmin - margin - compressdisplayzone;
lomax = plotmin - margin;
himin = plotmax + margin;
himax = plotmax + margin + compressdisplayzone;


extremeSettings.loextremelim = plotmin;
extremeSettings.hiextremelim = plotmax;
extremeSettings.locompressboundmin = lomin;
extremeSettings.locompressboundmax = lomax;
extremeSettings.hicompressboundmin = himin;
extremeSettings.hicompressboundmax = himax;

% Determine whether there are any extreme outliers.
cliplo = globalmin<plotmin;
cliphi = globalmax>plotmax;

clipLinepos = cell(1,0);
clipLineprops = cell(1,0);
% Select style for datalim line.
databoundStyle.color = 'k';
databoundStyle.linestyle = '--';
databoundStyle.linewidth = .5;
% Select style for compression zone lines.
compresszoneStyle.color = [.75 .75 .75];
compresszoneStyle.linestyle = '-';
compresszoneStyle.linewidth = .5;
% If we have low extreme data, we need to draw low lines.
i = 0;
if cliplo
    i = i+1;
    clipLinepos{i} = plotmin;
    clipLineprops{i} = databoundStyle;
    switch extrememode
        case 'compress'
            i = i+1;
            clipLinepos{i} = [lomin lomax];
            clipLineprops{i} = compresszoneStyle;
        case 'clip'
            % Do nothing, there is no compression zone.
        otherwise
            error('stats:boxplot:BadExtrememode',...
                'Bad value for ''extrememode'' parameter');
    end
end
% If we have high extreme data, we need to draw high lines.
if cliphi
    i = i+1;
    clipLinepos{i} = plotmax;
    clipLineprops{i} = databoundStyle;
    switch extrememode
        case 'compress'
            i = i+1;
            clipLinepos{i} = [himin himax];
            clipLineprops{i} = compresszoneStyle;
        case 'clip'
            % Do nothing, there is no compression zone.
        otherwise
            error('stats:boxplot:BadExtrememode',...
                'Bad value for ''extrememode'' parameter');
    end
end

% Determine data extents to use for autoscaling.
if cliplo
    dataAutoscaleLo = lomin;
else
    if isfinite(globalmin)
        % Empty and all-NaN data wind up in this case, with an arbitrary
        % value set above.
        dataAutoscaleLo = globalmin;
    else
        % Data contains one or more -infs, or is all inf.
        finiteData = isfinite(xSorted) & groupVisibleByPointSorted;
        if any(finiteData)
            dataAutoscaleLo = min(xSorted(finiteData));
        else
            % No finite data, setting arbitrary value.
            dataAutoscaleLo = 0;
        end
    end
end
if cliphi
    dataAutoscaleHi = himax;
else
    if isfinite(globalmax)
        % Empty and all-NaN data wind up in this case, with an arbitrary
        % value set above.
        dataAutoscaleHi = globalmax;
    else
        % Data contains one or more infs, or is all -inf.
        finiteData = isfinite(xSorted) & groupVisibleByPointSorted;
        if any(finiteData)
            dataAutoscaleHi = max(xSorted(finiteData));
        else
            % No finite data, setting arbitrary value.
            dataAutoscaleHi = 1;
        end
    end
end
dataPlotLimits = [dataAutoscaleLo,dataAutoscaleHi];

end


%----------------------------
% Compute where data-axis details will go, for all boxes.
% boxValDs is a dataset containing the statistics and outlier values for
%   each group.
% boxValPlotDs is a dataset with the same fields as boxValDs, but the
%   values may be different to reflect that data beyond the datalim's gets
%   adjusted.
% boxIdxDs is a dataset with a subset of the fields of boxValDs.
%   Rather than holding the actual value, it holds the corresponding index
%   into xSorted.  Note that quantiles may have non-integer indices.
function [boxValDs,boxValPlotDs, boxIdxDs]= computeBoxLocation...
    (xSorted,gStart,gEnd,whisker,numFlatGroups,extrememode,...
    extremeSettings,origRow)

% Loop over each flat group.
% Extract vector of data.
% Compute stats on it.
% Stash stats into an array of structs.
% At the end, copy all data into a dataset.

% Get row of empty structs.
[boxVal,boxValPlot,boxIdx] = computeGroupStats([], 0,0,...
    extrememode,extremeSettings,[]);
% If no data anywhere in the plot, bail out.
if numFlatGroups==0
    boxValDs = dataset(boxVal);
    boxValPlotDs = dataset(boxValPlot);
    boxIdxDs = dataset(boxIdx);
    return
end
% Expand struct arrays to full size.
boxVal(numFlatGroups) = boxVal;
boxValPlot(numFlatGroups) = boxValPlot;
boxIdx(numFlatGroups) = boxIdx;

% Compute stats for each group, store in array of structs.
for i=1:numFlatGroups
    if ~isnan(gStart(i))
        xSorted1group = xSorted(gStart(i):gEnd(i));
    else
        xSorted1group = [];
    end
    [boxVal(i),boxValPlot(i),boxIdx(i)]=computeGroupStats(xSorted1group,...
        whisker,gStart(i),extrememode,extremeSettings,origRow);
end

% Copy data into datasets.
fn = fieldnames(boxVal);
boxValDs = dataset();
boxValPlotDs = dataset();

for i=1:length(fn)
    boxValVect=zeros(numFlatGroups,1);
    boxValPlotVect=zeros(numFlatGroups,1);
    boxValCell = cell(numFlatGroups,1);
    boxValPlotCell = cell(numFlatGroups,1);
    for j=1:numFlatGroups
        if ~iscell(boxVal(1).(fn{i}))
            boxValVect(j) = boxVal(j).(fn{i});
            boxValPlotVect(j) = boxValPlot(j).(fn{i});
        else
            boxValCell(j) = boxVal(j).(fn{i});
            boxValPlotCell(j) = boxValPlot(j).(fn{i});
        end
    end
    if ~iscell(boxVal(1).(fn{i}))
        boxValDs.(fn{i}) = boxValVect;
        boxValPlotDs.(fn{i}) = boxValPlotVect;
    else
        boxValDs.(fn{i}) = boxValCell;
        boxValPlotDs.(fn{i}) = boxValPlotCell;
    end
end

% Copy indices into dataset.
fn = fieldnames(boxIdx);

boxIdxDs=dataset();
for i=1:length(fn)
    boxIdxVect = zeros(numFlatGroups,1);
    boxIdxCell = cell(numFlatGroups,1);
    for j=1:numFlatGroups
        if ~iscell(boxIdx(1).(fn{i}))
            boxIdxVect(j) = boxIdx(j).(fn{i});
        else
            boxIdxCell(j) = boxIdx(j).(fn{i});
        end
    end
    if ~iscell(boxIdx(1).(fn{i}))
        boxIdxDs.(fn{i}) = boxIdxVect;
    else
        boxIdxDs.(fn{i}) = boxIdxCell;
    end
end

end

%----------------------------
% Compute where data-axis details will go, for 1 box.
% The statistics are returned in structs.  boxVal and boxValPlot have
% the same fields, but the data in boxValPlot may have been adjusted
% based on  extrememode.
function [boxVal,boxValPlot,boxIdx]=...
    computeGroupStats(xSorted1group,whisker,gStart,...
    extrememode,extremeSettings,origRow)

boxIdx = computeBoxIndices(xSorted1group, whisker,gStart);

if boxIdx.empty==1
    % If no data in the group, or it is all nan, then no points will be
    % clipped. Thus, there is no need to warp the data for plotting.
    boxVal=computeBoxValues(xSorted1group,boxIdx,origRow);
    boxValPlot=computeBoxValues(xSorted1group,boxIdx,origRow);
    return;
end

% Now guaranteed at least 1 non-nan datapoint.
% Clip or transform extreme data.
extremeloind = find(xSorted1group<extremeSettings.loextremelim);
extremehiind = find(xSorted1group>extremeSettings.hiextremelim);
xWarped = xSorted1group;
switch extrememode
    case 'compress',
        % Evenly space extreme points throughout the compression zone,
        % retaining their original ordering.  If there is only one point,
        % put it on the bound farthest from the middle.
        if ~isempty (extremeloind)
            xWarped(extremeloind(end:-1:1)) = ...
                linspace(extremeSettings.locompressboundmax,...
                extremeSettings.locompressboundmin,length(extremeloind));
        end
        if ~isempty (extremehiind)
            xWarped(extremehiind) = ...
                linspace(extremeSettings.hicompressboundmin,...
                extremeSettings.hicompressboundmax,length(extremehiind));
        end
        
    case 'clip'
        % Pull extreme points in to the clipping limits.
        xWarped(extremeloind)= extremeSettings.loextremelim;
        xWarped(extremehiind)= extremeSettings.hiextremelim;
    otherwise
        error('stats:boxplot:BadExtremeSettingsMode',...
            '''extrememode'' parameter has an invalid value')
end

% Compute stats on the original data, for use in numerical display.
boxVal = computeBoxValues(xSorted1group,boxIdx,origRow);

% Compute stats on the warped data, for use in plotting.
boxValPlot = computeBoxValues(xWarped,boxIdx,origRow);

% Fix quartiles on the plotted version of the points.
boxValPlot.q1 = tweakCompressedQuantile...
    (boxIdx.q1,boxVal.q1,boxValPlot.q1,...
    xSorted1group,gStart,extremeSettings,'snaplo');
boxValPlot.q2 = tweakCompressedQuantile...
    (boxIdx.q2,boxVal.q2,boxValPlot.q2,...
    xSorted1group,gStart,extremeSettings,'snaphi');
boxValPlot.q3 = tweakCompressedQuantile...
    (boxIdx.q3,boxVal.q3,boxValPlot.q3,...
    xSorted1group,gStart,extremeSettings,'snaphi');

% If median was not shifted, leave notches unshifted.
% If median was shifted, turn notches off.
if boxVal.q2 == boxValPlot.q2
    boxValPlot.nlo = boxVal.nlo;
    boxValPlot.nhi = boxVal.nhi;
else
    boxValPlot.nlo = nan;
    boxValPlot.nhi = nan;
end

end

%----------------------------
% Check whether the two points used to calculate the quantile
% are on opposite sides of a data limit.  If so, either put the
% quantile back in the right spot between the limits, or snap it to
% the edge of the compression region.
function qValPlot = tweakCompressedQuantile(qIdx,qVal,qValPlot,...
    xSorted1group,gStart,extremeSettings,snaplohi)
qIdx = qIdx-gStart+1;
if xSorted1group(floor(qIdx))<=extremeSettings.loextremelim && ...
        xSorted1group(ceil(qIdx))>=extremeSettings.hiextremelim
    % q's points straddle both upper and lower limits.
    
    % Snap to edge of compression zone.
    switch snaplohi
        case 'snaplo',qValPlot = extremeSettings.locompressboundmax;
        case 'snaphi',qValPlot = extremeSettings.hicompressboundmin;
        otherwise
            error('stats:toolbox:InvalidSnapLoHi',...
                'Invalid value for snaplohi');
    end

elseif xSorted1group(floor(qIdx))<=extremeSettings.loextremelim && ...
        xSorted1group(ceil(qIdx))>=extremeSettings.loextremelim
    % q's points straddle the lower limit.
    
    % If quantile was pulled out of bounds by 1 of its two
    % dependents, pull it back in.
    if qVal>=extremeSettings.loextremelim
        qValPlot = qVal;
        % Otherwise, snap it to the max edge of the lower compression zone.
    else
        qValPlot = extremeSettings.locompressboundmax;
    end

elseif xSorted1group(floor(qIdx))<=extremeSettings.hiextremelim && ...
        xSorted1group(ceil(qIdx))>=extremeSettings.hiextremelim
    % q's points straddle the upper limit.
    
    % If quantile was pulled out of bounds by 1 of its two
    % dependents, pull it back in.
    if qVal<=extremeSettings.hiextremelim
        qValPlot = qVal;
        % Otherwise, snap it to the min edge of the upper compression zone.
    else
        qValPlot = extremeSettings.hicompressboundmin;
    end
else
    % Either q's points are both clipped or are both inside the limits.
    % Do nothing.
end

end

%----------------------------
% Calculate the indices for all the rank statistics.
% All indices are relative to xSorted, not xSorted1group.
function [boxidx]=computeBoxIndices(xSorted1group,whisker,gStart)
boxidx.empty = 1;
boxidx.minimum = nan;
boxidx.wlo = nan;
boxidx.q1 = nan;
boxidx.q2 = nan;
boxidx.q3 = nan;
boxidx.whi = nan;
boxidx.maximum = nan;
boxidx.numNans = 0;
boxidx.outliers = cell(1,1);
boxidx.numLoOutliers = 0;
boxidx.numHiOutliers = 0;

if isempty(xSorted1group)
    return;
end

% Compute bounds of the non-nan data.  Also count the number of nan's...
% if everything is nan, then we are done.
firstind = 1;
firstnan = find(isnan(xSorted1group),1);
if isempty(firstnan) % No nan's.
    lastind = length(xSorted1group);
    boxidx.numNans = 0;
elseif firstnan==1 % All nan's.
    lastind = 1;
    boxidx.numNans = length(xSorted1group);
    return
else
    lastind = firstnan-1;% Some nan's.
    boxidx.numNans = length(xSorted1group)-lastind;
end

ind0 = gStart-1;
% Calculate 25,50,75 percentile indices.
if lastind > 1
    i25 = firstind+ .25*(lastind-firstind) -.25;
    i50 = firstind+ .50*(lastind-firstind);
    i75 = firstind+ .75*(lastind-firstind) +.25;
else
    i25 = 1;
    i50 = 1;
    i75 = 1;
end


% Compute actual quartile values by taking a weighted average.
% These are used just for determining which points are outliers.
p25Ratio = i25-floor(i25);
if p25Ratio==0
    p25 = xSorted1group(i25);
else
    p25 = xSorted1group(floor(i25))*(1-p25Ratio) ...
        +xSorted1group(ceil(i25))*p25Ratio;
end

p75Ratio = i75-floor(i75);
if p75Ratio==0
    p75 = xSorted1group(i75);
else
    p75 = xSorted1group(floor(i75))*(1-p75Ratio) ...
        +xSorted1group(ceil(i75))*p75Ratio;
end

% Standard percentile function would be slower.
%     p = prctile(xSorted1group,[25 75]);
%     p25 = p(1);
%     p75 = p(2);

% Calculate whisker endpoints.
maxw = p75+whisker*(p75-p25);
if ~isfinite(maxw)
    maxw = inf;
end
minw = p25-whisker*(p75-p25);
if ~isfinite(minw)
    minw = -inf;
end

whi = find(xSorted1group<=maxw,1,'last');
if isempty(whi)
    whi = lastind;
end
wlo = find(xSorted1group>=minw,1,'first');
if isempty(wlo)
    wlo = firstind;
end

% Bundle up outlier indices.
outlo = (1:wlo-1)';
outhi = (whi+1:lastind)';
outall = [outlo;outhi];

numLoOutliers = length(outlo);
numHiOutliers = length(outhi);

% Store everything into a structure, adding an offset so the indices align
% with xSorted.
boxidx.empty = 0;
boxidx.minimum = firstind+ind0;
boxidx.wlo = wlo+ind0;
boxidx.q1 = i25+ind0;
boxidx.q2 = i50+ind0;
boxidx.q3 = i75+ind0;
boxidx.whi = whi+ind0;
boxidx.maximum = lastind+ind0;
boxidx.outliers = {outall+ind0};
boxidx.numLoOutliers = numLoOutliers;
boxidx.numHiOutliers = numHiOutliers;

end

%----------------------------
% Convert the index values into data values.
function boxval = computeBoxValues(x,boxidx,origRow)
% Initialize defaults, and create struct in correct order.
boxval.minimum = nan;
boxval.wlo = nan;
boxval.q1 = nan;
boxval.nlo = nan;
boxval.q2 = nan;
boxval.nhi = nan;
boxval.q3 = nan;
boxval.whi = nan;
boxval.maximum = nan;
boxval.outliers = cell(1,1);
boxval.numPts = nan;
boxval.numNans = boxidx.numNans;
boxval.numInfs = 0;
boxval.numFiniteLoOutliers = 0;
boxval.numFiniteHiOutliers = 0;
boxval.outlierrows = cell(1,1);

if boxidx.empty
    % X is empty or contains all NaN's.
    boxval.numPts = length(x);
    return
end

% Convert indices to map into xSorted1group... or xWarped.
ind0 = boxidx.minimum-1;
i25 = boxidx.q1-ind0;
i50 = boxidx.q2-ind0;
i75 = boxidx.q3-ind0;

% Compute weighted average.
p25Ratio = i25-floor(i25);
if p25Ratio==0
    p25 = x(i25);
else
    p25 = x(floor(i25))*(1-p25Ratio) ...
        +x(ceil(i25))*p25Ratio;
end

p50Ratio = i50-floor(i50);
if p50Ratio==0
    p50 = x(i50);
else
    p50 = x(floor(i50))*(1-p50Ratio) ...
        +x(ceil(i50))*p50Ratio;
end

p75Ratio = i75-floor(i75);
if p75Ratio==0
    p75 = x(i75);
else
    p75 = x(floor(i75))*(1-p75Ratio) ...
        +x(ceil(i75))*p75Ratio;
end

% Standard percentile function is slower.
%     p = prctile(x,[25 50 75]);
%     p25 = p(1);
%     p50 = p(2);
%     p75 = p(3);

% Compute notches around the median, based on the quantiles.
nhi = p50 + 1.57*(p75-p25)/sqrt(length(x));
if ~isfinite(nhi)
    nhi = p50;
end
nlo = p50 - 1.57*(p75-p25)/sqrt(length(x));
if ~isfinite(nlo)
    nlo = p50;
end


% Prevent notches from extending past edge of box.
% These are commented out because they give prettier but misleading
% information.
% if nhi>p75, nhi = p75; end
% if nlo<p25, nlo = p25; end

wlo = x(boxidx.wlo-ind0);
whi=x(boxidx.whi-ind0);

% Ensure whiskers are not inside box - this may happen for small samples,
% when the most extreme non-outlier is between the quartiles.
wlo = min(wlo,p25);
whi = max(whi,p75);

outliers = x(boxidx.outliers{1}-ind0);
outlierrows = origRow(boxidx.outliers{1});

numFiniteLoOutliers = sum(isfinite(outliers(1:boxidx.numLoOutliers)));
numFiniteHiOutliers = ...
    sum(isfinite(outliers(end-boxidx.numHiOutliers+1:end)));


% Store computations into structure.
boxval.minimum = x(boxidx.minimum-ind0);
boxval.wlo = wlo;
boxval.q1 = p25;
boxval.nlo = nlo;
boxval.q2 = p50;
boxval.nhi = nhi;
boxval.q3 = p75;
boxval.whi = whi;
boxval.maximum=  x(boxidx.maximum-ind0);
boxval.outliers = {outliers};
boxval.numPts = length(x);
boxval.numNans = boxidx.numNans;
boxval.numInfs = sum(isinf(x));
boxval.numFiniteLoOutliers = numFiniteLoOutliers;
boxval.numFiniteHiOutliers = numFiniteHiOutliers;
boxval.outlierrows = {outlierrows};

end

%----------------------------
% Compute where each box goes along the factor axis, as well as where
% separator lines would go for each grouping variable.
% The boxes may be pushed around by positions and factorgap.
% Earlier, they may have been pushed around by fullfactors, which can
%  insert empty boxes.  In addition, earlier they may have been re-ordered
%  by positions and grouporder, such that upon entering this function the
%  groups are monotonically increasing along the factor axis.
function [gPos,factorsepPos] = ...
    computeBoxPosition(labelIndexByGroup,positionValueByGroup,...
    factorgap,numFlatGroups,numGroupVars)

if strcmp(factorgap,'auto')
    % Select gaps that are reasonable when there are many boxes.
    % Note that the compact plotstyle causes factorgap to default to
    % auto.
    if numGroupVars==1, factorgap = [];
    elseif numGroupVars==2, factorgap = 2;
    elseif numGroupVars>2, factorgap = [2 1];
    else
        error('stats:boxplot:BadNumGroupVars',...
            'Invalid internal value for numGroupVars');
    end
end


% Compute breakpoints, ie where the given factor changes from one row to
% the next.  This depends on the groups being monotonically increasing, so
% that adjacent boxes are adjacent rows in labelIndexByGroup.
visibleBoxes = find(isfinite(positionValueByGroup));
numVisibleBoxes = size(visibleBoxes,1);
breakpoints = diff(labelIndexByGroup(visibleBoxes,:))~=0;

if isempty(factorgap) || numFlatGroups==0 || numVisibleBoxes==0
    gPos = positionValueByGroup;
elseif isvector(factorgap) && isnumeric(factorgap) && ...
        all(factorgap>=0) && length(factorgap)<=numGroupVars
    
    % Convert factorgap to percentage of total width of boxes.
    visiblePositions = positionValueByGroup(visibleBoxes);
    span = max(visiblePositions) - min(visiblePositions);
    factorgap = factorgap*span/100;
    
    gapfactornums = find(factorgap);
    % Copy breaks over one column at a time. Do not copy the break over if
    % it corresponds to one that was set by a more major factor.
    breakfactor = zeros(numVisibleBoxes-1,1);
    for i=1:length(gapfactornums)
        newbreak = breakfactor==0 & breakpoints(:,gapfactornums(i))~=0;
        breakfactor(newbreak) = gapfactornums(i);
    end
    % Prepend 0 to make breakfactor align with other lengths.
    breakfactor = [0;breakfactor];
    % Convert gap factor index to gap spacing value; zero index maps to the
    % value zero.
    gaprows = find(breakfactor);
    groupgaps = zeros(numVisibleBoxes,1);
    groupgaps(gaprows) = factorgap(breakfactor(gaprows));
    
    % Add gaps into the existing box spacing.
    baselinespacing = [visiblePositions(1);diff(visiblePositions)];
    gPosVisible = cumsum(groupgaps+baselinespacing);
    % NaN and Inf positions retain their original position, finite
    % positions are shifted to make room for the factor gaps.
    gPos = positionValueByGroup;
    gPos(visibleBoxes) = gPosVisible;
else
    error('stats:boxplot:BadFactorGap', ...
        ['The ''factorgap'' parameter value must be a numeric vector ',...
        'of positive values, with length less than or equal to the ',...
        'number of grouping variables.']);
end

% Determine where separator lines would go for each grouping variable
factorsepPos = cell(1,numGroupVars);
if numVisibleBoxes>1
    breakpointsExpanded = zeros(numFlatGroups-1,numGroupVars);
    breakpointsExpanded(visibleBoxes(2:end)-1,:) = breakpoints;
    sepfactor = zeros(numFlatGroups-1,1);
    for i=1:numGroupVars
        newsep = sepfactor==0 & breakpointsExpanded(:,i)~=0;
        sepfactor(newsep) = i;
    end
    % Compute midpoint of each gap; gPos assumed to be monotonic.
    seppos = gPos(1:end-1) + diff(gPos)/2;
    % Bundle up the separator positions.
    for i=1:numGroupVars
        factorsepPos{i} = seppos(sepfactor==i);
    end
end

end

%----------------------------
% Determine the width of each box.
% gWidth is a vector with one value per box.
% maxGuaranteedGap is a scalar, giving half of the closest spacing
%   between box centers.
function [gWidth,maxGuaranteedGap] = ...
    computeBoxWidth(gPos, widths,numFlatGroups)

% Compute maxGuaranteedGap, based on positions.  With default positions,
%  maxGuaranteedGap will be .5.
numVisibleBoxes = sum(isfinite(gPos));
maxGuaranteedGap = .5;
if numVisibleBoxes>1
    % gPos is guaranteed to be sorted, so visible boxes will be adjacent
    % to each other.
    boxgaps = diff(gPos(isfinite(gPos)));
    boxgaps(boxgaps==0) = []; % Don't consider boxes at identical position.
    if ~isempty(boxgaps)
        maxGuaranteedGap = .5*min(boxgaps);
    end
end

% Compute gWidth for all boxes, whether or not they are visible.
if isempty(widths)
    % Choose default widths.
    % If there are not many groups, make the boxes narrower than they would
    %  be otherwise.
    if numVisibleBoxes>3
        gWidth = maxGuaranteedGap;
    else
        gWidth = numVisibleBoxes*.3*maxGuaranteedGap;
    end
    gWidth = repmat(gWidth,numFlatGroups,1);
else
    % User specified widths.
    if length(widths)~=numFlatGroups
        % Wrap widths as many times as needed, then cut to length
        % numFlatGroups.
        gWidth = repmat(widths,ceil(numFlatGroups/length(widths)),1);
        gWidth = gWidth(1:numFlatGroups);
    else
        gWidth = widths;
    end
end

end


%----------------------------
% Choose the location and styles of factor separator lines.
function [factorsepLinepos, factorsepLineprops]=computeBoxSeparators...
    (factorseparator,factorsepPos,numGroupVars)

% If auto, choose factor separator lines appropriate for many groups.
% Note that the compact plotstyle causes factorseparator to default to
% auto.
if strcmp(factorseparator,'auto')
    if numGroupVars>=3
        factorseparator = 1;
    else
        factorseparator = [];
    end
end

if isempty(factorseparator)
    factorsepLinepos = {};
    factorsepLineprops = [];
else
    if ~all(ismember(factorseparator,1:numGroupVars))
        error('stats:boxplot:BadFactorseparator', ...
            ['The ''factorseparator'' parameter value must ',...
            'be a numeric vector with values between 1 and ',...
            'the number of group variables.']);
    end
    factorseparatorUniq = unique(factorseparator);
    factorsepLinepos = factorsepPos(factorseparatorUniq);
    numSepFactors = length(factorsepLinepos);
    % Choose line properties.
    lineprops.color = [.75 .75 .75];
    lineprops.linestyle = '-';
    lineprops.linewidth = .5;
    % Make all the line styles the same.
    factorsepLineprops = cell(1,numSepFactors);
    for i=1:numSepFactors
        factorsepLineprops{i} = lineprops;
    end
end

end


%----------------------------
% Choose how much to jitter each outlier.
% Note that the jitter argument is a user specified parameter, and its
%  default depends on the plotstyle parameter.
function outlierOffsetPos = computeOutlierJitter...
    (outlierLoc, jitter,numFlatGroups)

if numFlatGroups==0
    outlierOffsetPos = {[]};
else
    outlierOffsetPos=cell(numFlatGroups,1);
    if jitter==0
        for i=1:numFlatGroups
            outlierOffsetPos{i}=zeros(size(outlierLoc{i}));
        end
    else
        for i=1:numFlatGroups
            outlierOffsetPos{i}=jitter*2*(rand(size(outlierLoc{i}))-.5);
        end
    end
end
end

%----------------------------
% Choose colors for the elements of the box, also choose the outlier
% symbol.
function [cWhisker,cBox,cMedian,cOutlier,outlierSymbol]=...
    computeColor(colors,colorIndexByGroup,symbol,medianstyle,boxstyle)

% Select the color map.
% If colors is empty, select a colormap.
if isempty(colors)
    colorsExplicit = false;
    if isempty(colorIndexByGroup)
        % Everything is one color group, make it blue.
        cmap = 'b';
    else
        % Use a darkened hsv colormap.
        numColorGroups = length(unique(colorIndexByGroup));
        cmapLen = min(7,numColorGroups);
        cmap = hsv2rgb([ ...
            (0:cmapLen-1)'/cmapLen, ...
            ones(cmapLen,1), ...
            .75*ones(cmapLen,1) ]);
    end
else
    % Colors may be empty, a single char, a 3 element vector, a char
    %  vector, or a 3 column matrix
    % Check that it is valid, and then make sure it is in a column.
    colorsExplicit = true;
    if ischar(colors)
        % Make sure chars are in a column.
        cmap = colors(:);
    elseif isnumeric(colors)
        if numel(colors)==3
            cmap = reshape(colors,1,3); % 3 element vector.
        elseif size(colors,2)==3
            cmap = colors; % 3 column matrix.
        else
            error('stats:boxplot:BadColorsNumericArg',...
                ['A numeric ''colors'' parameter must be a ',...
                '3 element vector or a 3 column matrix']);
        end
    else
        error('stats:boxplot:BadColorsArg',...
            ['The ''colors'' parameter must be a 3 element vector, ',...
            'a 3 column matrix, a color character, or ',...
            'a string of color characters.']);
    end
    cmapLen = size(cmap,1);
end

% Color the boxes, wrapping the color group number as needed to constrain
%  it to the number of colors in cmap. cBox will be either 1 or
%  numFlatGroups long.
if isempty(colorIndexByGroup)
    cBox = cmap(1,:);
else
    cIdxUniqWrapped = mod(colorIndexByGroup-1,cmapLen)+1;
    cBox = cmap(cIdxUniqWrapped,:);
end

% Determine how to color the outliers.
[unusedLinestyle,cOutlier,outlierSymbol,msg] = colstyle(symbol);
if ~isempty(msg)
    error('stats:boxplot:BadSymbol',msg.message);
end

% Handle empty color or symbol.
if strcmp(cOutlier,'')
    cOutlier = cBox;
end

if strcmp(outlierSymbol,'')
    outlierSymbol = 'n'; % 'n' will later map to marker='none'.
end

% Color the median line and the whisker.  With the traditional plotstyle,
%  specifying a box color forces both to use the box color, otherwise they
%  take on their own color.
switch(medianstyle)
    case 'line',
        if colorsExplicit
            cMedian = cBox;
        else
            cMedian = 'r';
        end
    case 'target',
        cMedian = 'k';
    otherwise
        error('stats:boxplot:BadMedianStyle',...
            'Bad value for ''medianstyle'' argument');
end

switch(boxstyle)
    case 'outline',
        if colorsExplicit
            cWhisker = cBox;
        else
            cWhisker = 'k';
        end
    case 'filled',
        cWhisker = cBox;
    otherwise
        error('stats:boxplot:BadBoxStyle',...
            'Bad value for ''boxstyle'' argument');
end

end

%----------------------------
% Compute the axis limits, adding some margin around the data.
function axislims=computeAxesMargin(orientation,gPos,gWidth,...
    dataPlotLimits,boxValPlot)

visibleBoxes = isfinite(gPos);
visiblePositions = gPos(visibleBoxes);
% Compute margin in the factor axis.
% Leave room around the two most extreme boxes.
posMin = min(visiblePositions);
posMax = max(visiblePositions);
factorspan = posMax-posMin;
if isempty(factorspan) || isnan(factorspan)
    % No data to plot, setting arbitrary limits.
    factoraxMin = 0;
    factoraxMax = 1;
else
    if factorspan~=0
        factormargin = max(max(gWidth), 0.5*min(diff(visiblePositions)));
    else
        factormargin = max(0.5,max(gWidth));
    end
    % Compute factor axis limits.
    factoraxMin = posMin-factormargin;
    factoraxMax = posMax+factormargin;
end

% Compute margin in the data axis.
% Leave a buffer that is a fixed percentage of the data width.
% Consider only those boxes that will actually be visible.

% First unpack previously calculated data min and max plot bounds.
datamin = dataPlotLimits(1);
datamax = dataPlotLimits(2);
% If there are notches, ensure they are inside the plot bounds as well.
notchLo = boxValPlot.nlo;
notchHi = boxValPlot.nhi;
notchVisible = visibleBoxes & isfinite(notchLo) & isfinite(notchHi);
if any(notchVisible)
    notchmin = min(notchLo(notchVisible));
    notchmax = max(notchHi(notchVisible));
    datamin = min([datamin,notchmin]);
    datamax = max([datamax,notchmax]);
end

% Compute a margin as a fixed percentage, unless all the points are the
% same value.
buffer = .05;
dataspan = datamax-datamin;
if dataspan~=0
    datamargin = buffer*dataspan;
else
    datamargin = .5;
end
% Compute data axis limits.
dataAxMin = datamin - datamargin;
dataAxMax = datamax + datamargin;


% Map data and factor axis limits to x and y.
switch orientation
    case 'vertical',
        axislims = [factoraxMin factoraxMax dataAxMin dataAxMax];
    case 'horizontal',
        axislims = [dataAxMin dataAxMax factoraxMin factoraxMax];
    otherwise
        error('stats:boxplot:BadOrientation',...
            'Bad value for ''Orientation'' parameter');
end

end

%----------------------------
% When you have text labels on the y axis, it is nice when they start from
% the top.
function factorAxisDir = computeFactorAxisDir...
    (orientation,factordirection,gDat,gexplicit,labelsExplicit)
if strcmp(factordirection,'auto')
    if (gexplicit && ~isnumeric(gDat{1})) || labelsExplicit
        factordirection = 'list';
    else
        factordirection = 'data';
    end
end

switch orientation
    case 'vertical',
        factorAxisDir = 'normal';
    case 'horizontal'
        switch factordirection
            case 'data'
                factorAxisDir = 'normal';
            case 'list'
                % Flip the Y axis.
                factorAxisDir = 'reverse';
            otherwise
                error('stats:boxplot:BadFactordirection',...
                    'Invalid value for ''factordirection'' parameter');
        end
    otherwise
        error('stats:boxplot:BadOrientation',...
            'Invalid value for ''orientation'' parameter');
end

end

%----------------------------
% Compute the contents and location of each text label for the factors.
% These will be used in place of axis ticks.
function [labelDataLocation,labelPtsPosition,labelText,...
    columnPtsPosition,displayLabel]=...
    computeBoxLabel...
    (ax,gPos,gLevelsByGroup,userLabelsByGroup,labelIndexByGroup,...
    labelverbosity,orientation,labelorientation,numFlatGroups,numGroupVars)

if ~isempty(userLabelsByGroup)
    plotLabels = userLabelsByGroup;
else
    plotLabels = gLevelsByGroup;
end

% Compute which labels are printed, based on the labelverbosity setting.
numLabelVars = length(plotLabels);

switch labelverbosity
    case {'all'}
        % Always display all labels.
        displayLabel = true(numFlatGroups,numLabelVars);
    case {'minor','majorminor'}
        % First consider each grouping variable independently.
        % Don't let non-displaying groups affect those that are visible.
        visibleBoxes = isfinite(gPos);
        if any(visibleBoxes)
            % If fewer label variables were given than there are group
            % vars, make the label variables follow the most major groups
            % and ignore the minor groups.
            numVerbosityLabels = min([numLabelVars,numGroupVars]);
            verbosityLabelIndexByGroup = ...
                labelIndexByGroup(:,1:numVerbosityLabels);
            % Display labels if the value is different for that factor in
            % the previous group.
            displayLabelVisible = diff([zeros(1,numVerbosityLabels);...
                verbosityLabelIndexByGroup(visibleBoxes,:)])~=0;
            % If more label variables were given than there are group vars,
            % turn on all the label vars more minor than the most minor
            % group var.
            displayLabelVisible(:,numVerbosityLabels+1:numLabelVars)=true;
            % Remap the rows for the visible groups back to the rows for
            % all groups.
            displayLabel = false(numFlatGroups,numLabelVars);
            displayLabel(visibleBoxes,:) = displayLabelVisible;
        else
            % All boxes are at non-finite positions and won't plot, so
            % leave all labels turned off.
            displayLabel = false(numFlatGroups,numLabelVars);
        end
        if strcmp(labelverbosity,'majorminor')
            % Each grouping variable is coupled to those more major.
            % That is, if a major label is displayed, also display all
            % labels minor to it.
            for i=2:numLabelVars
                displayLabel(:,i) = ...
                    displayLabel(:,i-1) | displayLabel(:,i);
            end
        end
    otherwise
        error('stats:boxplot:BadBoxStyle',...
            'Invalid value for the ''boxstyle'' parameter.');
end

% Measure the length of the longest label of each group, in points
% The font, etc for text() needs to match the call to text() in
%  renderLabels().
if ( strcmp(orientation,'horizontal') && ...
        strcmp(labelorientation,'horizontal')) || ...
        ((strcmp(orientation,'horizontal') && ...
        strcmp(labelorientation,'inline')))
    rot = 0;
    ind = 3;
    measwidth = true;
    firstgroupvarnearestaxis = false;
elseif strcmp(orientation,'vertical') && ...
        strcmp(labelorientation,'horizontal')
    rot = 0;
    ind = 4;
    measwidth = false;
    firstgroupvarnearestaxis = true;
elseif strcmp(orientation,'vertical') && ...
        strcmp(labelorientation,'inline')
    rot = 90;
    ind = 4;
    measwidth = true;
    firstgroupvarnearestaxis = false;
else
    error('stats:boxplot:BadOrientOrFactorOrient',...
        ['Bad value for ''orientation'' or ',...
        '''labelorientation'' parameters']);
end

columnPtsWidth = zeros(1,numLabelVars);
if measwidth
    % Measure the width of the widest label in each group.
    for i=1:numLabelVars
        h = text(0,0,plotLabels{i}(displayLabel(:,i)),...
            'parent',ax,'visible','off','Interpreter','none',...
            'units','points','Rotation',rot);
        ext = get(h,'Extent');
        columnPtsWidth(i) = ext(ind);
        delete(h);
    end
    % Pad each group except the first with extra space.
    labelSpacer = ' ';
    h = text(0,0,labelSpacer,'parent',ax,'visible','off',...
        'units','points','Rotation',rot,'Interpreter','none');
    ext = get(h,'Extent');
    delete(h);
    labelSpacerPts = ext(ind);
    columnPtsWidth(1:end-1) = columnPtsWidth(1:end-1) + labelSpacerPts;
else
    % Measure the height of one label, and copy it to each group.
    h = text(0,0,'42','parent',ax,'visible','off',...
        'units','points','Rotation',rot,'Interpreter','none');
    ext = get(h,'Extent');
    columnPtsWidth(:) = ext(ind);
    delete(h);
end

% Find starting point of each column, in points.
if firstgroupvarnearestaxis
    columnPtsPosition = -cumsum(columnPtsWidth);
else
    columnPtsPosition = -fliplr(cumsum(fliplr(columnPtsWidth)));
end

% Create position vectors for labels.
labelDataLocation = repmat(gPos,1,numLabelVars);
labelPtsPosition = repmat(columnPtsPosition,numFlatGroups,1);
labelText = cell(numFlatGroups,numLabelVars);
for i=1:numLabelVars
    labelText(:,i) = plotLabels{i};
end

% Package the labeling info. Store everything as column vectors.
displayLabel = displayLabel(:);
labelDataLocation = labelDataLocation(:);
labelPtsPosition = labelPtsPosition(:);
labelText = labelText(:);



end



% % Do Rendering - Helper Functions

%----------------------------
% Draw the factor axis labels.
% Sets up a callback to position the labels and make the right ones
% visible.
function h=renderLabels (labelDataLocation,labelPtsPosition,labelText,...
    columnPtsPosition,boxparent,orientation,labelorientation,...
    displayLabel)

numLabels = length(labelDataLocation);
ax = ancestor(boxparent,'axes');
% Select text properties.
if (strcmp(orientation,'horizontal') && ...
        strcmp(labelorientation,'horizontal')) || ...
        (strcmp(orientation,'horizontal') && ...
        strcmp(labelorientation,'inline'))
    rot = 0;
    labelAxis = 'y';
    tickProperty = 'ytick';
    tickLabelProperty = 'yticklabel';
    halign = 'left';
    valign = 'middle';
    axislabel = 'YLabel';
elseif strcmp(orientation,'vertical') && ...
        strcmp(labelorientation,'horizontal')
    rot = 0;
    labelAxis = 'x';
    tickProperty = 'xtick';
    tickLabelProperty = 'xticklabel';
    halign = 'center';
    valign = 'bottom';
    axislabel = 'XLabel';
elseif strcmp(orientation,'vertical') && ...
        strcmp(labelorientation,'inline')
    rot = 90;
    labelAxis = 'x';
    tickProperty = 'xtick';
    tickLabelProperty = 'xticklabel';
    halign = 'left';
    valign = 'middle';
    axislabel = 'XLabel';
else
    error('stats:boxplot:BadOrientOrFactorOrient',...
        ['Bad value for ''orientation'' or ',...
        '''labelorientation'' parameters']);
end
% Use dummy X and Y positions, as they will be set by the callback
% function. Put labels at a negative Z value, so the datatip box renders on
% top of them. Make all invisible, as visibility will be set by the
% callback function.
h = text(ones(numLabels,1),ones(numLabels,1),-1*ones(numLabels,1),...
    labelText,'Visible','off','Rotation',rot,...
    'HorizontalAlignment',halign,'VerticalAlignment',valign,...
    'Interpreter','none','Units','points','parent',boxparent);

% Set units of axis label to points.
haxlabel = get(ax,axislabel);
set(haxlabel,'Units','points');

% Store info with axis needed to adjust label positions.
% Note: this appdata is used by the datatip callback as well.
setappdata(boxparent,'plottype','boxplot');
setappdata(ax,'boxplothandle',boxparent);
setappdata(boxparent,'labelhandles',h);
setappdata(boxparent,'labelptspos',labelPtsPosition);
setappdata(boxparent,'labeldatloc',labelDataLocation);
setappdata(boxparent,'columnptsposition',columnPtsPosition);
setappdata(boxparent,'labelaxis',labelAxis);
setappdata(boxparent,'displaylabel',displayLabel);

set(ax,tickProperty,[]); % tickProperty is 'xtick' or 'ytick'.
set(ax,tickLabelProperty,[]); 

% Set ActivePositionProperty to make loose inset method work when inside a
% subplot. Need to draw first to get accurate results.
drawnow
set(ax,'ActivePositionProperty','OuterPosition');
op = get(ax,'OuterPosition');
if any(op(1:2)<0)
    li = get(ax,'LooseInset');
    for j=1:2     % loop over x and y
        if op(j)<0
            % If LooseInset is set up for an OuterPosition that starts at
            % a negative value, correct this to avoid problems later
            li(j) = li(j)+op(j);      % adjust inset to be measured from 0
            op(j+2) = op(j+2)+op(j);  % shrink width to be measured from 0
            op(j)=0;                  % move start outer position to 0
        end
    end
    set(ax,'OuterPosition',op,'LooseInset',li);
end

% Set callbacks.

% Call the callback manually the first time to finish setting up the
% labels.
repositionLabels(ax);

% Make listeners to invoke the callback when required
makelisteners(ax);

% Re-create these listeners if the figure is saved and loaded
setappdata(ax,'PostDeserializeFcn',@makelisteners);
end

% ------------------------------
function makelisteners(ax,varargin)

boxparent = getappdata(ax,'boxplothandle');
labelAxis = getappdata(boxparent,'labelaxis');

% Fire callback if window is resized.
f = ancestor(ax,'figure');
list1 = addlistener(f,'Resize',@(src,evt) repositionLabels(ax));

% Fire callback if certain axes properties change, eg axis limits due to
% zooming.
props = [{'DataAspectRatioMode' 'DataAspectRatio' 'WarpToFill' ...
          'XLim' 'YLim' 'Position'}, ...
         strcat(upper(labelAxis),{'Dir' 'Scale' 'TickLabel'})];
list2 = addlistener(ax, props, 'PostSet',@(src,evt) repositionLabels(ax));

% Get rid of listeners when we're done with them
setappdata(boxparent,'boxlisteners',[list1 list2]);
set(boxparent,'DeleteFcn',@removelisteners);
end

% ------------------------------
function removelisteners(src,varargin)
appd = getappdata(src,'boxlisteners');
for j=1:numel(appd)
    listj = appd(j);
    if isa(listj,'handle.listener')
        delete(listj)
    end
end
end
    
%----------------------------
% Set factor-axis label positions and visibility, and axes position.
% Shift labels to their correct spot, and adjust the axes size to
%  make sure the labels are visible. Permit the labels to be painted, now
%  that they are in the right spots. Leave invisible those labels not
%  required by the labelverbosity setting, or those that are off the edge
%  of the axis.
function repositionLabels(ax)

boxparent = getappdata(ax,'boxplothandle');
f = ancestor(ax,'figure');

% Guaranteed to be called only when a boxplot hggroup is in the axes, but
% doublecheck anyway.
if isempty(boxparent) || ~ishghandle(boxparent)
    return; % Not a boxplot.
end
plotType = getappdata(boxparent,'plottype');
if ~strcmp(plotType,'boxplot')
    return; % Not a boxplot.
end

% Fetch the appdata.
labelPtsPos = getappdata(boxparent,'labelptspos');
labelDatLoc = getappdata(boxparent,'labeldatloc');
labelHandles = getappdata(boxparent,'labelhandles');
columnPtsPosition = getappdata(boxparent,'columnptsposition');
labelAxis = getappdata(boxparent,'labelaxis');
displayLabel = getappdata(boxparent,'displaylabel');

switch(labelAxis)
    case 'x'
        dat = 1;
        edge = 2;
        datspan = 3;
        span = 4;
        labellimtag = 'XLim';
        labelscaletag = 'XScale';
        labeldirtag = 'XDir';
        axislabel = 'XLabel';
        axisticklabel = 'XTickLabel';
        axislimoffset = 1;
    case 'y'
        edge = 1;
        dat  = 2;
        span = 3;
        datspan = 4;
        labellimtag='YLim';
        labelscaletag = 'YScale';
        labeldirtag = 'YDir';
        axislabel = 'YLabel';
        axisticklabel = 'YTickLabel';
        axislimoffset = 3;
    otherwise
        % Something isn't set up right.
        return; % Abort from this axes with no warning.
end

% Check that each handle is still valid.
validHandles = ishghandle(labelHandles);
if ~any(validHandles)
    return; % No work to do, try another axes.
end

% Skip invalid handles, in case certain labels were deleted.
if ~all(validHandles)
    labelHandles = labelHandles(validHandles);
    labelPtsPos = labelPtsPos(validHandles);
    labelDatLoc = labelDatLoc(validHandles);
    displayLabel = displayLabel(validHandles);
end

% Get axis label handle.
haxlabel = get(ax,axislabel);
% Get tick label text.
ticklabel = get(ax,axisticklabel);

% Get the current axis position values.
li = get(ax,'LooseInset');
lid = get(double(f),'DefaultAxesLooseInset');
op = get(ax,'OuterPosition');

% Convert the axes position values to points.
liPts = hgconvertunits(ancestor(ax,'figure'),li, ...
    get(ax,'Units'),'points',get(ax,'Parent'));
lidPts = hgconvertunits(ancestor(ax,'figure'),lid, ...
    get(ax,'Units'),'points',get(ax,'Parent'));
opPts = hgconvertunits(ancestor(ax,'figure'),op, ...
    get(ax,'Units'),'points',get(ax,'Parent'));

% Determine how much room is available for tick labels, assuming the axes
% were squished to zero width.
maxAllowedWidthPts = opPts(span)-lidPts(edge)-lidPts(span);

% Determine how many factor labels we can fit.
if columnPtsPosition(1)<columnPtsPosition(end)
    % Inline labels.
    columnPosShifted = -columnPtsPosition(1)+[columnPtsPosition(2:end),0];
else
    % Stacked labels, or just one factor.
    columnPosShifted = -columnPtsPosition;
end
okcols = columnPosShifted<=maxAllowedWidthPts;
if ~isempty(okcols) && dat==1  % always show at least one label on x axis
    okcols(1) = 1;
end
numDisplayedFactors = find(okcols,1,'last');

% Determine how much room the labels require, and which specific labels
% will be displayed.  Labels are omitted if there is not enough room on the
% axes, beginning with the minor labels.
if isempty(numDisplayedFactors) || ~isempty(ticklabel)
    % All labels clipped.
    labelClipped = true(size(labelPtsPos));
    if isempty(ticklabel)
        actualWidthPts = 0; % if no factors displayed or empty tick labels
    else
        % Need to get measurements from current tick labels instead of
        % using ones from text measured originally
        if isequal(labelAxis,'y')
            sampletext = ticklabel; % to get max width of all labels
            ind = 3;
        else
            sampletext = '42'; % any single-line text will do
            ind = 4;
        end
        h = text(0,0,sampletext,'parent',ax,'visible','off', ...
                 'Interpreter','none','units','points');
        ext = get(h,'Extent');
        actualWidthPts = ext(ind);
        delete(h);
    end
elseif numDisplayedFactors==length(columnPosShifted)
    % No labels clipped.
    labelClipped = false(size(labelPtsPos));
    actualWidthPts = columnPosShifted(end);
else
    % Some, but not all, factor tick labels don't fit and will be clipped.
    if columnPtsPosition(1)<columnPtsPosition(end)
        % Inline labels.
        labelClipped = labelPtsPos>columnPtsPosition(numDisplayedFactors);
        % Slide the labels closer to the axis, to fill the gap left by
        % omitted labels.
        labelPtsPos = labelPtsPos...
            +columnPosShifted(end)...
            -columnPosShifted(numDisplayedFactors);
    else
        % Stacked labels.
        labelClipped = labelPtsPos<columnPtsPosition(numDisplayedFactors);
    end
    actualWidthPts = columnPosShifted(numDisplayedFactors);
end

% Adjust axes to accommodate the factor tick labels and any axis label.
% Set the other three edges to their default.
newLiPts(dat) = lidPts(dat);
newLiPts([span datspan]) = liPts([span datspan]);
newLiPts(edge) = lidPts(edge)+actualWidthPts;

% Convert back to original axes units.
newLi = hgconvertunits(ancestor(ax,'figure'),newLiPts, ...
    'points',get(ax,'Units'),get(ax,'Parent'));

% If the tick labels take up too much room, squish axis to 0 width but do
% not let its width go negative.  Do this in the original units, to avoid
% late roundoff.
if newLi(edge)+newLi(span)>op(span)
    newLi(edge) = max(0, op(span)-newLi(span));
end

% Set the margin needed around axes; the axes Position property
% will adjust itself.
set(ax,'LooseInset',newLi);

% Get the updated axes position.
p = get(ax,'Position');
pPts = hgconvertunits(ancestor(ax,'figure'),p, ...
    get(ax,'Units'),'points',get(ax,'Parent'));

% For non-warped axes (as in "axis square"), recalculate another way
if isequal(get(ax,'WarpToFill'),'off')
    xl = get(ax,'xlim');
    yl = get(ax,'ylim');
    
    % Use text to get coordinate (in points) of southwest corner
    t1 = text(xl(1),yl(1),'42','Visible','off');
    set(t1,'units','points');
    pSW = get(t1,'position');
    delete(t1);
    
    % Same for northeast corner
    t1 = text(xl(2),yl(2),'42','Visible','off');
    set(t1,'units','points');
    pNE = get(t1,'position');
    delete(t1);
    
    % Re-create position; we only care about the last two elements
    % Use min/max/abs in case one or more directions are reversed
    pPts = [min(pSW(1),pNE(1)),
            max(pSW(2),pNE(2)),
            abs(pNE(1)-pSW(1)),
            abs(pNE(2)-pSW(2))];
end

% Convert label tick locations from data to points units.

% Get the factor axis settings.
scale = get(ax,labelscaletag);
dir = get(ax,labeldirtag);
lim = get(ax,labellimtag);
if strcmp(scale,'log') && any(lim==0)
    % Find the actual limits by getting the hidden deprecated RenderLimits.
    oldstate = warning('off',...
        'MATLAB:HandleGraphics:NonfunctionalProperty:RenderLimits');
    renderlimits = get(ax,'RenderLimits');
    warning(oldstate);
    lim = renderlimits([axislimoffset,axislimoffset+1]);
end

% Map the label tick locations from data units into normalized units.
switch scale
    case 'linear'
        labelDatLocNorm = (labelDatLoc-lim(1))/(lim(2)-lim(1));
    case 'log'
        labelDatLocNorm = ...
            (log(labelDatLoc)-log(lim(1)))/(log(lim(2))-log(lim(1)));
    otherwise
        error('stats:boxplot:BadScale',...
            'Unexpected value for XScale or YScale axes property');
end
% Flip the direction, if requested.
switch dir
    case 'normal' %do nothing
    case 'reverse'
        labelDatLocNorm = 1-labelDatLocNorm;
    otherwise
        error('stats:boxplot:BadDir',...
            'Unexpected value for Xdir or Ydir axes property');
end
% Find which labels are outside the axis limits, so they will be made
% invisible.
labelOutOfRange = labelDatLocNorm<0 | labelDatLocNorm>1 ...
    | isnan(labelDatLocNorm);

% Map the normalized units into points units.
axisLengthPts = pPts(datspan);
labelDatLocPts = labelDatLocNorm*axisLengthPts;

% Fill a cell array with the label positions.
labelpos = cell(size(labelPtsPos));
onepos = zeros(1,3);
onepos(3) = -.1;  % Slight negative Z, so datatip appears in front.
for j=1:length(labelpos)
    onepos(dat) = labelDatLocPts(j);
    onepos(edge) = labelPtsPos(j);
    labelpos{j} = onepos;
end

% Set the label positions.  Be sure to specify points units, as
% the units may have changed (for example, during printing).
set(labelHandles,'Units','points',{'Position'},labelpos);

% Make labels within the limits visible, and those outside invisible.
% displayLabel makes some labels always invisible, based on the
% labelverbosity setting.
vis = displayLabel & ~labelOutOfRange & ~labelClipped;
visoptions = {'off';'on'};
visvalue = visoptions(vis+1);
set(labelHandles,{'Visible'},visvalue);

% Position the axis label
% Use slight negative Z, so datatip appears in front.
axlabelPtsposition(3) = -.1;
axlabelPtsposition(edge) = -(actualWidthPts+1);
axlabelPtsposition(dat) = pPts(datspan)/2;
set(haxlabel,'Position',axlabelPtsposition);

end

%----------------------------
% Select the direction of the factor axis.
function setFactorDirection(ax,orientation,factorAxisDir)
switch orientation
    case 'vertical',
        set(ax,'Xdir',factorAxisDir);
    case 'horizontal'
        set(ax,'Ydir',factorAxisDir);
    otherwise
        error('stats:boxplot:BadOrientation',...
            'Invalid value for ''orientation'' parameter');
end

end

%----------------------------
% Draw clipping lines.
function hclip = ...
    renderClippingLines(ax,clipLinepos,clipLineprops,orientation)

if isempty(clipLinepos)
    hclip = {};
    return
end

switch orientation
    case 'vertical',
        fdraw = @hline;
    case 'horizontal',
        fdraw = @vline;
    otherwise
        error('stats:boxplot:BadOrientation',...
            'Bad value for ''Orientation'' parameter');
end

numSepFactors = length(clipLinepos);
hclip = cell(numSepFactors,1);
for i=1:numSepFactors
    hclip{i} = fdraw(ax,clipLinepos{i},'Color',clipLineprops{i}.color,...
        'LineStyle',clipLineprops{i}.linestyle,...
        'LineWidth',clipLineprops{i}.linewidth);
end

end

%----------------------------
% Draw factor separator lines.
function hfactorseps=renderFactorSeparatorLines...
    (ax,factorsepLinepos, factorsepLineprops, orientation)

if isempty(factorsepLinepos)
    hfactorseps = {};
    return
end

switch orientation
    case 'vertical',
        fdraw = @vline;
    case 'horizontal',
        fdraw = @hline;
    otherwise
        error('stats:boxplot:BadOrientation',...
            'Bad value for ''Orientation'' parameter');
end

numSepFactors = length(factorsepLinepos);
hfactorseps = cell(numSepFactors,1);
for i=1:numSepFactors
    hfactorseps{i} = fdraw(ax,factorsepLinepos{i},...
        'Color',factorsepLineprops{i}.color,...
        'LineStyle',factorsepLineprops{i}.linestyle,...
        'LineWidth',factorsepLineprops{i}.linewidth);
end

end

%----------------------------
% Draw boxes, whiskers, and outliers. Return handles to all the line
% objects created.  The columns of hdata correspond to box groups, and the
% rows correspond to the various components used to draw the box. houtliers
% is just the outliers row from hdata.
function [hdata,houtliers]=renderBoxes(boxparent,gPos,...
    maxGuaranteedGap,orientation,...
    boxValPlot,cWhisker,cBox,cMedian,cOutlier,outlierSymbol, ...
    notch, medianstyle,boxstyle,gWidth,outliersize)

% Set notchdepth.
% This affects both outline-boxstyle notches and line-medianstyle medians.
switch notch
    case {'on'},
        notchdepth =.5;
   case {'off','marker'},
        notchdepth = 0;
    otherwise
        error('stats:boxplot:BadNotch',...
            'Bad value for ''notch'' parameter');
end

switch(boxstyle)
    case 'filled'
        % Draw filled-boxstyle whiskers.
        hwhisker = ...
            boxrenderer(boxparent,gPos,maxGuaranteedGap,orientation, ...  
            'lineAlongResponse',{...
                'locationstart',boxValPlot.wlo,...
                'locationend',boxValPlot.whi,...
                'linestyle','-','linewidth',.5,'linecolor',cWhisker,...
                'tag','Whisker'}...
            );
        % Draw filled-boxstyle box.           
        hbox = ...
            boxrenderer(boxparent,gPos,maxGuaranteedGap,orientation, ...  
            'lineAlongResponse',{...
                'locationstart',boxValPlot.q1,...
                'locationend',boxValPlot.q3,...
                'linestyle','-','linewidth',4,'linecolor',cBox,...
                'tag','Box'}...
            );
            
    case 'outline',
        % Draw outline-boxstyle whiskers.
        hwhisker = ...
            boxrenderer(boxparent,gPos,gWidth,orientation, ...
            'lineAlongResponse',{...
                'locationstart',boxValPlot.q3,...
                'locationend',boxValPlot.whi,...
                'linestyle','--','linewidth',.5,'linecolor',cWhisker,...
                'tag','Upper Whisker'},...
            'lineAlongResponse',{...
                'locationstart',boxValPlot.wlo,...
                'locationend',boxValPlot.q1,...
                'linestyle','--','linewidth',.5,'linecolor',cWhisker,...
                'tag','Lower Whisker'},...
            'lineAlongFactor',{'location',boxValPlot.whi,...
                'linelength',.5,...
                'linestyle','-','linewidth',.5,'linecolor',cWhisker,...
                'tag','Upper Adjacent Value'},...
            'lineAlongFactor',{'location',boxValPlot.wlo,...
                'linelength',.5,...
                'linestyle','-','linewidth',.5,'linecolor',cWhisker,...
                'tag','Lower Adjacent Value'}...
            );
        % Draw outline-boxstyle box.
        switch notch
            case 'on',
                hbox = ...
                    boxrenderer(boxparent,gPos,gWidth,orientation, ...
                    'lineBoxNotched',{...
                        'locationstart',boxValPlot.q1,...
                        'locationend',boxValPlot.q3,...
                        'notchstart',boxValPlot.nlo,...
                        'notchmiddle',boxValPlot.q2,...
                        'notchend',boxValPlot.nhi,...
                        'notchdepth',notchdepth,...
                        'linestyle','-','linewidth',.5,'linecolor',cBox,...
                        'tag','Box'}...
                    );
            case {'off','marker'}
                hbox = ...
                    boxrenderer(boxparent,gPos,gWidth,orientation, ...
                    'lineBox',{...
                        'locationstart',boxValPlot.q1,...
                        'locationend',boxValPlot.q3,...
                        'linestyle','-','linewidth',.5,'linecolor',cBox,...
                        'tag','Box'}...
                );
            otherwise
                error('stats:boxplot:BadNotch',...
                    'Bad value for ''notch'' parameter');
        end
    otherwise
        error('stats:boxplot:BadBoxstyle',...
            'Bad value for ''boxstyle'' parameter');
end

% Draw medians.
switch (medianstyle)
    case 'target',
        hmedian = ...
            boxrenderer(boxparent,gPos,maxGuaranteedGap,orientation, ...          
            'marker',{'location',boxValPlot.q2,...
                'jitter',0,'markertype','o',...
                'markersize',6,'markercolor',cBox,'markerfill','b',...
                'tag','MedianOuter'}, ...
            'marker',{'location',boxValPlot.q2,...
                'jitter',0,'markertype','.',...
                'markersize',6,'markercolor',cMedian,...
                'tag','MedianInner'} ...
            );
    case 'line',
        hmedian = ...
            boxrenderer(boxparent,gPos,gWidth,orientation, ...   
            'lineAlongFactor',{'location',boxValPlot.q2,...
                'linelength',1-notchdepth,...
                'linestyle','-','linewidth',.5,'linecolor',cMedian,...
                'tag','Median'}...
            );
    otherwise
        error('stats:boxplot:BadMedianstyle',...
            'Bad value for ''medianstyle'' parameter');
end        

% Draw median-colored triangles to represent the notches.
if  (strcmp(notch,'on')     && strcmp(boxstyle,'filled')) || ...
    (strcmp(notch,'marker') && strcmp(boxstyle,'filled')) ||...
    (strcmp(notch,'marker') && strcmp(boxstyle,'outline'))

    switch orientation % Set the notch symbols.
        case 'vertical',
            nloSymbol = '^';
            nhiSymbol = 'v';
        case 'horizontal',
            nloSymbol = '>';
            nhiSymbol = '<';
        otherwise
            error('stats:boxplot:BadOrientation',...
                'Bad value for ''Orientation'' parameter');
    end

    hnotch = ...
        boxrenderer(boxparent,gPos,maxGuaranteedGap,orientation, ...
        'marker',{'location',boxValPlot.nlo,...
            'jitter',0,'markertype',nloSymbol,...
            'markersize',6,'markercolor',cMedian,'offset',0,...
            'tag','NotchLo'},...
        'marker',{'location',boxValPlot.nhi,...
            'jitter',0,'markertype',nhiSymbol,...
            'markersize',6,'markercolor',cMedian,'offset',0,...
            'tag','NotchHi'}...
        );
else
    hnotch = [];
end

% Draw the outliers.
% Jitter is added via the offset parameter.
houtliers = ...
    boxrenderer(boxparent,gPos,maxGuaranteedGap,orientation, ...  
     'marker',{'location',boxValPlot.outliers,...
        'jitter',0,'markertype',outlierSymbol,...
        'markersize',outliersize,'markercolor',cOutlier,...
        'offset',boxValPlot.outlierjitter,...
        'tag','Outliers'}...
    );

hdata = [hwhisker;hbox;hmedian;houtliers;hnotch];
end



%----------------------------
% Store the x and y locations of each outlier, sorted the same way as x was
% originally passed in. Pull data directly out of line objects.
function storeGnameInfo(ax,houtliers,origInd,boxIdx,numFlatGroups,xlen)

xdat = nan(xlen,1);
ydat = nan(xlen,1);
for i=1:numFlatGroups
    if isnan(houtliers(i))
        continue % No outliers for this group.
    end
    inds = origInd(boxIdx.outliers{i});
    x = get(houtliers(i),'Xdata');
    y = get(houtliers(i),'Ydata');
    xdat(inds) = x;
    ydat(inds) = y;
end

% Store information for gname function in UserData.
set(ax, 'UserData', {'boxplot' ydat xdat 1});

end

%----------------------------
% Store info for the datatip callback, and configure the custom datatip.
% Note that additional appdata is set in renderLabels().
function storeDatatipInfo(axhg,hdata,houtliers,hclip,hfactorseps,...
    boxVal,boxValPlot,gPos,notch,numFlatGroups)

setappdata(axhg,'outlierhandles',houtliers);
setappdata(axhg,'datahandles',hdata);
setappdata(axhg,'boxval',boxVal);
setappdata(axhg,'boxvalplot',boxValPlot);
setappdata(axhg,'gpos',gPos);
setappdata(axhg,'numflatgroups',numFlatGroups);

switch notch
    case {'off'}, notchOn = false;
    case {'on','marker'}, notchOn = true;
    otherwise 
        error('stats:boxplot:BadNotch',...
            'Bad value for ''notch'' parameter');
end
setappdata(axhg,'notchon',notchOn);

% Attach custom datacursor callback to each of the lines just drawn.
dataCursorBehaviorObjDatatip = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObjDatatip,'UpdateFcn',...
    {@boxplotDatatipCallback,axhg});
set(dataCursorBehaviorObjDatatip,'UpdateDataCursorFcn',...
    {@boxplotUpdateDataCursorCallback,axhg});
set(dataCursorBehaviorObjDatatip,'MoveDataCursorFcn',...
    {@boxplotMoveDataCursorCallback,axhg});
hgaddbehavior(hdata(~isnan(hdata)),dataCursorBehaviorObjDatatip);


% Disable data cursor from the clipping and separator lines, so we don't
% even get the default datatip.
dataCursorBehaviorObjDisabled = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObjDisabled,'Enable',false);
hgaddbehavior([hclip{:}],dataCursorBehaviorObjDisabled);
hgaddbehavior([hfactorseps{:}],dataCursorBehaviorObjDisabled);

end

%----------------------------
% Specify data cursor position based on mouse click.
function boxplotUpdateDataCursorCallback(hDataCursor,target,boxparent)

% Ensure that we are in a boxplot.
if isempty(boxparent) || ~ishghandle(boxparent)
    return; % Not a boxplot.
end
plotType=getappdata(boxparent,'plottype');
if ~strcmp(plotType,'boxplot');
    return; % Not a boxplot.
end

% Get data from axes.
labelAxis = getappdata(boxparent,'labelaxis');
gPos = getappdata(boxparent,'gpos');
boxValPlot = getappdata(boxparent,'boxvalplot');
notchOn = getappdata(boxparent,'notchon');
dataHandles = getappdata(boxparent,'datahandles');

% Map the target point to position and data.
switch labelAxis
    case 'x'
        selectPos = target(1,1);
        selectData = target(1,2);
    case 'y'
        selectData = target(1,1);
        selectPos = target(1,2);
    otherwise
        return; % Something is wrong.
end


% Determine which group is nearest to the mouse click.
visibleBoxes = find(isfinite(gPos));
if isempty(visibleBoxes)
    return; % No visible boxes, leave data cursor where it was.
end
[unusedMin,selectedGroup] = min(abs(gPos(visibleBoxes)-selectPos));
selectedGroup = visibleBoxes(selectedGroup);

% Get the warped data associated with the selected group.
groupPlotInfo = boxValPlot(selectedGroup,:);

groupData = zeros(7+length(groupPlotInfo.outliers{1}),1);
groupData(1) = groupPlotInfo.wlo;
groupData(2) = groupPlotInfo.q1;
groupData(3) = groupPlotInfo.nlo;
groupData(4) = groupPlotInfo.q2;
groupData(5) = groupPlotInfo.nhi;
groupData(6) = groupPlotInfo.q3;
groupData(7) = groupPlotInfo.whi;
groupData(8:end) = groupPlotInfo.outliers{1};
% If notches were not plotted, do not permit data cursor to land on them.
if ~notchOn
    groupData(3) = NaN;
    groupData(5) = NaN;
end

% Find nearest visible value.
visibleValues = find(isfinite(groupData));
if isempty(visibleValues)
    return; % No visible values, leave data cursor where it was.
end
[unusedMin,selectedComponent] = ...
    min(abs(groupData(visibleValues)-selectData));
selectedComponent = visibleValues(selectedComponent);

if selectedComponent>7
        % An outlier has been selected - use the vertex picker to select
        % which one, in case point has been jittered.
        % Get handle to outlier line.
        groupHandles = dataHandles(:,selectedGroup);
        groupTags = get(groupHandles,'Tag');
        outlierHandleIndex = strmatch('Outliers',groupTags);
        outlierHandle = groupHandles(outlierHandleIndex);
        
        [p,v,outlierIndex,pfactor] = ...
            vertexpicker(outlierHandle,target,'-force');
        selectedComponent = 7+outlierIndex;
        
        outlierXData = get(outlierHandle,'XData');
        outlierYData = get(outlierHandle,'YData');
        cursorXPosition = outlierXData(outlierIndex);
        cursorYPosition = outlierYData(outlierIndex);
else
    switch labelAxis
        case 'x'
            cursorXPosition = gPos(selectedGroup);
            cursorYPosition = groupData(selectedComponent);
        case 'y'
            cursorXPosition = groupData(selectedComponent);
            cursorYPosition = gPos(selectedGroup);
        otherwise
            return; % Something is wrong.
    end
end

% Update the data cursor.
set(hDataCursor,'Position',[cursorXPosition, cursorYPosition, 0]);
set(hDataCursor,'DataIndex',0);
set(hDataCursor,'TargetPoint',[selectedGroup selectedComponent]);



end

%----------------------------
% Specifies data cursor position when user selects arrows keys 
% (up,down,left,right).
function boxplotMoveDataCursorCallback(hDataCursor,dir,boxparent)

% Ensure that we are in a boxplot.
if isempty(boxparent) || ~ishghandle(boxparent)
    return; % Not a boxplot.
end
plotType=getappdata(boxparent,'plottype');
if ~strcmp(plotType,'boxplot');
    return; % Not a boxplot.
end

pos = get(hDataCursor,'TargetPoint');
selectedGroup = pos(1);
selectedComponent = pos(2);

% Get data from axes.
labelAxis = getappdata(boxparent,'labelaxis');
gPos = getappdata(boxparent,'gpos');
boxValPlot = getappdata(boxparent,'boxvalplot');
notchOn = getappdata(boxparent,'notchon');
dataHandles = getappdata(boxparent,'datahandles');
ax = ancestor(boxparent,'axes');

% Determine whether we are moving along the data or factor axis.
switch dir
    case {'up','down'}
        switch labelAxis
            case 'x', arrowAxis = 'data';
            case 'y', arrowAxis = 'factor';
            otherwise, return; % Error.
        end
        arrowAxisDir = get(ax,'ydir');
    case {'left','right'}
        switch labelAxis
            case 'x', arrowAxis = 'factor';
            case 'y', arrowAxis = 'data';
            otherwise, return; % Error.
        end
        arrowAxisDir = get(ax,'xdir');
    otherwise, return % Error.
end

% Determine direction index should move.
switch arrowAxisDir
    case 'normal'
        switch dir
            case {'up','right'}, indexShift = 1;
            case {'down','left'}, indexShift = -1;
            otherwise, return; % Error.
        end
    case 'reverse'
        switch dir
            case {'up','right'}, indexShift = -1;
            case {'down','left'}, indexShift = 1;
            otherwise, return; % Error.
        end
    otherwise, return; % Error.
end

% Determine legal values for new index.
switch arrowAxis
    case 'data'
        % Get the warped data associated with the selected group.
        groupPlotInfo = boxValPlot(selectedGroup,:);
        
        boxData = zeros(7,1);
        boxData(1) = groupPlotInfo.wlo;
        boxData(2) = groupPlotInfo.q1;
        boxData(3) = groupPlotInfo.nlo;
        boxData(4) = groupPlotInfo.q2;
        boxData(5) = groupPlotInfo.nhi;
        boxData(6) = groupPlotInfo.q3;
        boxData(7) = groupPlotInfo.whi;
        % Don't allow notches to be selected if they aren't displayed.
        if ~notchOn 
            boxData(3) = NaN;
            boxData(5) = NaN;
        end
        groupData = [boxData; groupPlotInfo.outliers{1}];
        % Find data points that are plottable.
        validInds = find(isfinite(groupData));
        % Get current index, among the plottable points.
        currentInd = find(validInds==selectedComponent);
        if isempty(currentInd)
             % Error, somehow the current index is not on a visible point
             return;
        end
        % Propose new index, among plottable points.
        newInd = currentInd+indexShift;
        
        % Apply wrapping - low outliers should appear below box, and high
        % outliers above box.
        if groupPlotInfo.numFiniteLoOutliers>0
            numValidBoxInds = sum(isfinite(boxData));
            % Create zone map:
            % 1-before start, 2-in box, 3-lo outliers, 4-hi outliers, 
            % 5-after end
            % Assume that box and hi outlier zones could be empty.
            zoneEnds = cumsum([0 numValidBoxInds ...
                groupPlotInfo.numFiniteLoOutliers ...
                groupPlotInfo.numFiniteHiOutliers ...
                1]);
            zoneStarts = [0 zoneEnds(1:end-1)+1];
            newIndIncreasing = zoneStarts([3 3 4 2 5]); % First 2 not used.
            newIndDecreasing = zoneEnds([3 1 2 4 4]); % Last 2 not used.
            currentIndZone = ...
                find(currentInd>=zoneStarts&currentInd<=zoneEnds);
            newIndZone = find(newInd>=zoneStarts&newInd<=zoneEnds);
            % If cursor crosses into a new zone, wrap it to the right one.
            if newIndZone==5 && currentIndZone==3 && numValidBoxInds>0
                % No hi outliers, place index on low end of box.
                newInd = 1;
            elseif newIndZone>currentIndZone
                newInd = newIndIncreasing(newIndZone);
            elseif newIndZone<currentIndZone
                newInd = newIndDecreasing(newIndZone);
            end
        end
        
        % Check that new position is not off the end.
        if newInd<1 || newInd>length(validInds)
            return; % Do not attempt to arrow off the end of the data.
        end
        % Map index back to the complete set of points.
        selectedComponent = validInds(newInd);
    case 'factor'
        % Box at a visible position, and the median is visible as well.
        validInds = find(isfinite(gPos) & isfinite(boxValPlot.q2));
        % Get current index.
        currentInd = find(validInds==selectedGroup);
        if isempty(currentInd)
             % Error, somehow the current index is not on a visible point
             return;
        end
        newInd = currentInd+indexShift;
        if newInd<1 || newInd>length(validInds)
            return; % Do not attempt to arrow off the end of the groups.
        end
        selectedGroup = validInds(newInd);
        % Choose which component is selected on the new group.
        % If it was on a box component before, keep it on the same
        % one if the new one is visible, otherwise just put it on the
        % median.
        
        % Get the info for the new group. Don't bother with the outliers,
        % as the outliers will never be selected when changing groups.
        groupPlotInfo = boxValPlot(selectedGroup,:);
        groupData = zeros(7,1);
        groupData(1) = groupPlotInfo.wlo;
        groupData(2) = groupPlotInfo.q1;
        groupData(3) = groupPlotInfo.nlo;
        groupData(4) = groupPlotInfo.q2;
        groupData(5) = groupPlotInfo.nhi;
        groupData(6) = groupPlotInfo.q3;
        groupData(7) = groupPlotInfo.whi;
        
        if selectedComponent>7 || ~isfinite(groupData(selectedComponent))
            selectedComponent = 4; % New median verified to be finite.
        end
end

% Select the new X and Y position of the data cursor.
if selectedComponent>7
        % Outlier selected, find the X and Y value from line properties.
        % Get handle to outlier line.
        groupHandles = dataHandles(:,selectedGroup);
        groupTags = get(groupHandles,'Tag');
        outlierHandleIndex = strmatch('Outliers',groupTags);
        outlierHandle = groupHandles(outlierHandleIndex);
        % Compute index into the line.
        outlierIndex = selectedComponent-7;
        % Extract the point value from the line handle.
        outlierXData = get(outlierHandle,'XData');
        outlierYData = get(outlierHandle,'YData');
        cursorXPosition = outlierXData(outlierIndex);
        cursorYPosition = outlierYData(outlierIndex);
else
    % Box component selected, center the data tip in the box.
    switch labelAxis
        case 'x'
            cursorXPosition = gPos(selectedGroup);
            cursorYPosition = groupData(selectedComponent);
        case 'y'
            cursorXPosition = groupData(selectedComponent);
            cursorYPosition = gPos(selectedGroup);
        otherwise
            return; % Something is wrong.
    end
end

% Update the data cursor.
set(hDataCursor,'Position',[cursorXPosition, cursorYPosition, 0]);
set(hDataCursor,'DataIndex',0);
set(hDataCursor,'TargetPoint',[selectedGroup selectedComponent]);



end

%----------------------------
% Generate text used in the datatip.
% This code must be kept in sync with boxrenderer() and renderBoxes().
function datatipTxt = boxplotDatatipCallback(obj,evt,boxparent)

% First, figure out where we are.
pos = get(evt,'Position');
selectedGroup = pos(1);
selectedComponent = pos(2);

% Ensure that we are in a boxplot.
if isempty(boxparent) || ~ishghandle(boxparent)
    datatipTxt = '';
    return; % Not a boxplot.
end
plotType=getappdata(boxparent,'plottype');
if ~strcmp(plotType,'boxplot');
    datatipTxt = '';
    return; % Not a boxplot.
end

% Now that we have a valid handle to a boxplot, get the appdata.
boxVal = getappdata(boxparent,'boxval');
labelHandles = getappdata(boxparent,'labelhandles');
numFlatGroups = getappdata(boxparent,'numflatgroups');


% Get the un-warped data associated with the selected group.
groupInfo = boxVal(selectedGroup,:);

% Generate group label based on how the axis is labeled.
groupLabelHandles = labelHandles(selectedGroup:numFlatGroups:end);
groupLabels = get(groupLabelHandles,'String');
if iscell(groupLabels) 
    % Append multiple columns of labels.
    groupLabels = sprintf('%s  ',groupLabels{:});
end

% Calculate number of nans and infs in this group.
% Base it on the original data rather than the plot - +/- inf may be
% plotted if the datalim parameter is changed from its default.
numNansAndInfs = groupInfo.numNans+groupInfo.numInfs;
numFiniteOutliers = groupInfo.numFiniteLoOutliers+...
    groupInfo.numFiniteHiOutliers;

if selectedComponent<=7
    % Generate datatip for a box component.
    % Generate context sensitive portion of the output string.
    switch selectedComponent
        case 1  %'Lower Adjacent'
            datatipTxt = {['Lower Adjacent: ',num2str(groupInfo.wlo)]};
        case 2  %'25th Percentile'
            datatipTxt = {['25th Percentile: ',num2str(groupInfo.q1)]};
        case 3  % 'Lo Notch'
            datatipTxt = {['Lo Notch: ',num2str(groupInfo.nlo)]};
        case 4  % 'Median'
            datatipTxt = {['Median: ',num2str(groupInfo.q2)]};
        case 5  % 'Hi Notch'
            datatipTxt = {['Hi Notch: ',num2str(groupInfo.nhi)]};
        case 6  % '75th Percentile'
            datatipTxt = {['75th Percentile: ',num2str(groupInfo.q3)]};
        case 7  % 'Upper Adjacent'
            datatipTxt = {['Upper Adjacent: ',num2str(groupInfo.whi)]};
        otherwise
            datatipTxt = '';
            return; % Error.
    end
    % Append general group info to the context sensitive portion.
    datatipTxt = {datatipTxt{:},...
        [''],...
        ['Group: ',groupLabels],...
        [''],...
        ['Maximum: ',num2str(groupInfo.maximum)],...
        ['Minimum: ',num2str(groupInfo.minimum)],...
        ['Num Points: ',num2str(groupInfo.numPts)],...
        ['Num Finite Outliers: ',num2str(numFiniteOutliers)],...
        ['Num NaN''s or Inf''s: ',num2str(numNansAndInfs)],...
        };
    
    
    
else
    %Generate datatip for an outlier point.
    ind = selectedComponent-7;
    % Get outlier value before clipping or compression.
    groupOutlierValues = groupInfo.outliers{1};
    groupOutlierRows = groupInfo.outlierrows{1};
    cursorValue = groupOutlierValues(ind);
    % Determine whether other outliers in this group have the identical
    % value.
    multiIndLogical = groupOutlierValues==cursorValue;
    % Get original row index of the outlier(s), before any re-sorting.
    cursorRows = groupOutlierRows(multiIndLogical);
    
    distToMedian = cursorValue-groupInfo.q2;
    numIqrsToMedian = distToMedian/(groupInfo.q3-groupInfo.q1);
    
    datatipTxt = {
        ['Outlier Value: ' num2str(cursorValue)],...
        [''],...
        };
    
    % Generate different text depending on the number of outliers
    % sharing the identical value.
    handful = 5;
    if length(cursorRows)==1
        % Handle just one outlier.
        datatipTxt = {datatipTxt{:},...
            ['Observation Row: ' num2str(cursorRows)],...
            };
    elseif length(cursorRows)<=handful
        % Handle a small handful of outliers.
        cursorRowsChar = num2str(cursorRows','%d,');
        cursorRowsChar(end) = [];
        datatipTxt = {datatipTxt{:},...
            ['Observation Rows: ' cursorRowsChar],...
            ['Num Outliers At This Value: ' ...
            num2str(length(cursorRows))],...
            };
    else
        % Handle many outliers.
        % Display just the first handful of row indices.
        cursorRowsChar = num2str(cursorRows(1:handful)','%d,');
        cursorRowsChar(end) = [];
        datatipTxt = {datatipTxt{:},...
            ['Observation Rows: ' cursorRowsChar '...'],...
            ['Num Outliers At This Value: ' ...
            num2str(length(cursorRows))],...
            };
    end
    
    datatipTxt = {datatipTxt{:},...
        ['Group: ',groupLabels],...
        [''],...
        ['Distance To Median: ' num2str(distToMedian)],...
        ['Num IQRs To Median: ' num2str(numIqrsToMedian)],...
        };
    
end



end
