function [h,scores] = biplotPmtk(coefs,varargin)
%BIPLOT Biplot of variable/factor coefficients and scores.
%   BIPLOT(COEFS) creates a biplot of the coefficients in the matrix
%   COEFS.  The biplot is 2D if COEFS has two columns, or 3D if it has
%   three columns.  COEFS usually contains principal component coefficients
%   created with PRINCOMP or PCACOV, or factor loadings estimated with
%   FACTORAN or NNMF.  The axes in the biplot represent the principal
%   components or latent factors (columns of COEFS), and the observed
%   variables (rows of COEFS) are represented as vectors.
%
%   BIPLOT(COEFS, ..., 'Scores', SCORES) plots both COEFS and the scores in
%   the matrix SCORES in the biplot.  SCORES usually contains principal
%   component scores created with PRINCOMP or factor scores estimated with
%   FACTORAN.  Each observation (row of SCORES) is represented as a point
%   in the biplot.
%
%   A biplot allows you to visualize the magnitude and sign of each
%   variable's contribution to the first two or three principal components,
%   and how each observation is represented in terms of those components.
%   Use the data cursor to read precise values from the plot.
%
%   BIPLOT imposes a sign convention, forcing the element with largest
%   magnitude in each column of COEFS is positive.
%
%   BIPLOT(COEFS, ..., 'VarLabels',VARLABS) labels each vector (variable)
%   with the text in the character array or cell array VARLABS.
%
%   BIPLOT(COEFS, ..., 'Scores', SCORES, 'ObsLabels', OBSLABS) uses the
%   text in the character array or cell array OBSLABS as observation names
%   when displaying data cursors.
%
%   BIPLOT(COEFS, ..., 'Positive', true) restricts the biplot to the positive
%   quadrant (in 2D) or octant (in 3D). BIPLOT(COEFS, ..., 'Positive', false)
%   (the default) makes the biplot over the range +/- MAX(COEFS(:)) for all
%   coordinates.
%
%   BIPLOT(COEFFS, ..., 'PropertyName',PropertyValue, ...) sets properties
%   to the specified property values for all line graphics objects created
%   by BIPLOT.
%
%   H = BIPLOT(COEFS, ...) returns a column vector of handles to the
%   graphics objects created by BIPLOT.  H contains, in order, handles
%   corresponding to variables (line handles, followed by marker handles,
%   followed by text handles), to observations (if present, marker
%   handles), and to the axis lines.
%
%   Example:
%
%      load carsmall
%      X = [Acceleration Displacement Horsepower MPG Weight];
%      X = X(all(~isnan(X),2),:);
%      [coefs,score] = princomp(zscore(X));
%      vlabs = {'Accel','Disp','HP','MPG','Wgt'};
%      biplot(coefs(:,1:3), 'scores',score(:,1:3), 'varlabels',vlabs);
%
%   See also FACTORAN, NNMF, PRINCOMP, PCACOV, ROTATEFACTORS.

%   References:
%     [1] Seber, G.A.F. (1984) Multivariate Observations, Wiley.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.10 $ $Date: 2009/05/07 18:30:20 $

% Choose whether the datatip can attach to Axes or Variable lines.
cursorOnAxes = false;
cursorOnVars = true;

if nargin < 1
    error('stats:biplot:TooFewInputs', ...
          'At least one input argument required.');
end
[p,d] = size(coefs);
if (d < 2) || (d > 3)
    error('stats:biplot:WrongNumberOfDimensions', ...
          'COEFS must have 2 or 3 columns.');
elseif isempty(coefs)
    error('stats:biplot:EmptyInput', 'COEFS may not be an empty matrix.');
end
in3D = (d == 3);

% Process input parameter name/value pairs, assume unrecognized ones are
% graphics properties for PLOT.
pnames = {'scores' 'varlabels' 'obslabels' 'positive'};
dflts =  {     []          []          []         [] };
[errid,errmsg,scores,varlabs,obslabs,positive,plotArgs] = ...
                    internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:biplot:%s',errid), errmsg);
end

if ~isempty(scores)
    [n,d2] = size(scores);
    if d2 ~= d
        error('stats:biplot:WrongNumberOfDimensions', ...
              'SCORES must have the same number of columns as COEFS.');
    end
end

if ~isempty(positive)
    if ~isscalar(positive) || ~islogical(positive)
        error('stats:biplot:InvalidPositive', ...
              'POSITIVE must be true or false.');
    end
else
    positive = false;
end

cax = newplot;
dataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObj,'UpdateFcn',@biplotDatatipCallback);
disabledDataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(disabledDataCursorBehaviorObj,'Enable',false);

if nargout > 0
    varTxtHndl = [];
    obsHndl = [];
    axisHndl = [];
end

% Force each column of the coefficients to have a positive largest element.
% This tends to put the large var vectors in the top and right halves of
% the plot.
[dum,maxind] = max(abs(coefs),[],1); %#ok<ASGLU>
colsign = sign(coefs(maxind + (0:p:(d-1)*p)));
coefs = coefs .* repmat(colsign, p, 1);

% Plot a line with a head for each variable, and label them.  Pass along any
% extra input args as graphics properties for plot.
%
% Create separate objects for the lines and markers for each row of COEFS.
zeroes = zeros(p,1); nans = NaN(p,1);
arx = [zeroes coefs(:,1) nans]';
ary = [zeroes coefs(:,2) nans]';
if in3D
    arz = [zeroes coefs(:,3) nans]';
    varHndl = [line(arx(1:2,:),ary(1:2,:),arz(1:2,:), 'Color','b', 'LineStyle','-', plotArgs{:}, 'Marker','none'); ...
               line(arx(2:3,:),ary(2:3,:),arz(2:3,:), 'Color','b', 'Marker','.', plotArgs{:}, 'LineStyle','none')];
else
    varHndl = [line(arx(1:2,:),ary(1:2,:), 'Color','b', 'LineStyle','-', plotArgs{:}, 'Marker','none'); ...
               line(arx(2:3,:),ary(2:3,:), 'Color','b', 'Marker','.', plotArgs{:}, 'LineStyle','none')];
end
set(varHndl(1:p),'tag','varline');
set(varHndl((p+1):(2*p)),'tag','varmarker');
set(varHndl,{'UserData'},num2cell(([1:p 1:p])'));
if cursorOnVars
    hgaddbehavior(varHndl,dataCursorBehaviorObj);
else
    hgaddbehavior(varHndl,disabledDataCursorBehaviorObj);
end


if ~isempty(varlabs)
    if ~(ischar(varlabs) && (size(varlabs,1) == p)) && ...
                           ~(iscellstr(varlabs) && (numel(varlabs) == p))
        error('stats:biplot:InvalidVarLabels', ...
              ['The ''varlabels'' parameter value must be a character array or ' ...
               'a cell array\nof strings with one label for each row of COEFS.']);
    end

    % Take a stab at keeping the labels off the markers.
    delx = .01*diff(get(cax,'XLim'));
    dely = .01*diff(get(cax,'YLim'));
    if in3D
        delz = .01*diff(get(cax,'ZLim'));
    end

    if in3D
        varTxtHndl = text(coefs(:,1)+delx,coefs(:,2)+dely,coefs(:,3)+delz,varlabs);
    else
        varTxtHndl = text(coefs(:,1)+delx,coefs(:,2)+dely,varlabs);
    end
    set(varTxtHndl,'tag','varlabel');
end

% Plot axes and label the figure.
if ~ishold
    view(d), grid on;
    axlimHi = 1.1*max(abs(coefs(:)));
    axlimLo = -axlimHi * ~positive;
    if in3D
        axisHndl = line([axlimLo axlimHi NaN 0 0 NaN 0 0],[0 0 NaN axlimLo axlimHi NaN 0 0],[0 0 NaN 0 0 NaN axlimLo axlimHi], 'Color','black');
    else
        axisHndl = line([axlimLo axlimHi NaN 0 0],[0 0 NaN axlimLo axlimHi], 'Color','black');
    end
    set(axisHndl,'tag','axisline');
    if cursorOnAxes
        hgaddbehavior(axisHndl,dataCursorBehaviorObj);
    else
        hgaddbehavior(axisHndl,disabledDataCursorBehaviorObj);
    end


    xlabel('Component 1');
    ylabel('Component 2');
    if in3D
        zlabel('Component 3');
    end
    axis tight
end

% Plot data.
if ~isempty(scores)
    % Scale the scores so they fit on the plot, and change the sign of
    % their coordinates according to the sign convention for the coefs.
    maxCoefLen = sqrt(max(sum(coefs.^2,2)));
    scores = maxCoefLen.*(scores ./ max(abs(scores(:)))) .* repmat(colsign, n, 1);
    
    % Create separate objects for each row of SCORES.
    nans = NaN(n,1);
    ptx = [scores(:,1) nans]';
    pty = [scores(:,2) nans]';
    % Plot a point for each observation, and label them.
    if in3D
        ptz = [scores(:,3) nans]';
        obsHndl = line(ptx,pty,ptz, 'Color','r', 'Marker','.', plotArgs{:}, 'LineStyle','none');
    else
        obsHndl = line(ptx,pty, 'Color','r', 'Marker','.', plotArgs{:}, 'LineStyle','none');
    end
    if ~isempty(obslabs)
        if ~(ischar(obslabs) && (size(obslabs,1) == n)) && ...
                           ~(iscellstr(obslabs) && (numel(obslabs) == n))
            error('stats:biplot:InvalidObsLabels', ...
                  ['The ''obslabels'' parameter value must be a character array or ' ...
                   'a cell array\nof strings with one label for each row of SCORES.']);
        end
    end
    set(obsHndl,'tag','obsmarker');
    set(obsHndl,{'UserData'},num2cell((1:n)'));
    hgaddbehavior(obsHndl,dataCursorBehaviorObj);
end

if ~ishold && positive
    axlims = axis;
    axlims(1:2:end) = 0;
    axis(axlims);
end

if nargout > 0
    h = [varHndl; varTxtHndl; obsHndl; axisHndl];
end

    % -----------------------------------------
    % Generate text for custom datatip.
    function dataCursorText = biplotDatatipCallback(obj,eventObj)
    clickPos = get(eventObj,'Position');
    clickTgt = get(eventObj,'Target');
    clickNum = get(clickTgt,'UserData');
    ind = get(eventObj,'DataIndex');
    switch get(clickTgt,'tag')
    case 'obsmarker'
        dataCursorText = {'Scores' ...
            ['Component 1: ' num2str(clickPos(1))] ...
            ['Component 2: ' num2str(clickPos(2))] };
        if in3D
            dataCursorText{end+1} = ['Component 3: ' num2str(clickPos(3))];
        end
        if isempty(obslabs)
            clickLabel =  num2str(clickNum);
        elseif ischar(obslabs)
            clickLabel = obslabs(clickNum,:);
        elseif iscellstr(obslabs)
            clickLabel = obslabs{clickNum};
        end
        dataCursorText{end+1} = '';
        dataCursorText{end+1} = ['Observation: ' clickLabel];
    case {'varmarker' 'varline'}
        dataCursorText = {'Loadings' ...
            ['Component 1: ' num2str(clickPos(1))] ...
            ['Component 2: ' num2str(clickPos(2))] };
        if in3D
            dataCursorText{end+1} = ['Component 3: ' num2str(clickPos(3))];
        end
        if isempty(varlabs)
            clickLabel = num2str(clickNum);
        elseif ischar(varlabs)
            clickLabel = varlabs(clickNum,:);
        elseif iscellstr(varlabs)
            clickLabel = varlabs{clickNum};
        end
        dataCursorText{end+1} = '';
        dataCursorText{end+1} = ['Variable: ' clickLabel];
    case 'axisline'
        comp = ceil(ind/3);
        dataCursorText = ['Component: ' num2str(comp)];
    otherwise
        dataCursorText = {...
            ['Component 1: ' num2str(clickPos(1))] ...
            ['Component 2: ' num2str(clickPos(2))]};
        if in3D
            dataCursorText{end+1} = ['Component 3: ' num2str(clickPos(3))];
        end
    end

    end % biplotDatatipCallback

end % biplot
