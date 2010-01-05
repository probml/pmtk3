function [] = prettyPlot(xData,yData,legendStr,plotTitle,plotXlabel,plotYlabel,type,style,errors)
% prettyPlot(xData,yData,legendStr,plotTitle,plotXlabel,plotYlabel,type,style,errors)
%
% type 0: plot
% type 1: semilogx
%
% style -1: matlab style
% style 0: use line styles
% style 1: use markers
%
% Save as image:
% set(gcf, 'PaperPositionMode', 'auto');
% print -depsc2 finalPlot1.eps

if nargin < 7
    type = 0;
end

if nargin < 8
    style = 0;
end

if nargin < 9
    errors = [];
end

if style == -1 % Matlab style
    doLineStyle = 0;
    doMarker = 0;
    lineWidth = 1.5;
    colors = getColorsRGB;
elseif style == 0 % Paper style (line styles)
    doLineStyle = 1;
    doMarker = 0;
    lineWidth = 3;
    colors = [.5 0 0
        0 .5 0
        0 0 .5
        0 .5 .5
        .5 .5 0];
else % Paper style (markers)
    doLineStyle = 0;
    doMarker = 1;
    lineWidth = 3;
    colors = [.5 0 0
        0 .5 0
        0 0 .5
        0 .5 .5
        .5 .5 0];
end

if type == 1
    plotFunc = @semilogx;
else
    plotFunc = @plot;
end

if isempty(xData)
    for i = 1:length(yData)
            h(i) = plotFunc(1:length(yData{i}),yData{i});

        applyStyle(h(i),i,colors,doLineStyle,doMarker,lineWidth)
        hold on;
    end
elseif iscell(xData)
    for i = 1:length(yData)
        h(i) = plotFunc(xData{i}-xData{i}(1),yData{i});

        applyStyle(h(i),i,colors,doLineStyle,doMarker,lineWidth)
        hold on;
    end
elseif iscell(yData)
    for i = 1:length(yData)
        if length(yData{i}) >= length(xData)
                h(i) = plotFunc(xData,yData{i}(1:length(xData)));
        else
                if isscalar(yData{i})
                    h(i) = hline(yData{i},'-');
                else
                    h(i) = plotFunc(xData(1:length(yData{i})),yData{i});
                end
        end

        applyStyle(h(i),i,colors,doLineStyle,doMarker,lineWidth)
        hold on;
    end
else
    for i = 1:size(yData,2)
            h(i) = plotFunc(xData,yData(:,i));

        applyStyle(h(i),i,colors,doLineStyle,doMarker,lineWidth)
        hold on;
    end
end

set(gca,'FontName','AvantGarde','FontWeight','normal','FontSize',12);

if ~isempty(legendStr)
    h = legend(h,legendStr);
    set(h,'FontSize',10,'FontWeight','normal');
    set(h,'Location','NorthWest');
end

h = title(plotTitle);
set(h,'FontName','AvantGarde','FontSize',10,'FontWeight','bold');

h1 = xlabel(plotXlabel);
h2 = ylabel(plotYlabel);
set([h1 h2],'FontName','AvantGarde','FontSize',14,'FontWeight','normal');

set(gca, ...
    'Box'         , 'on'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'      , ...
    'YMinorTick'  , 'off'      , ...
    'LineWidth'   , 1         );
%    'YGrid'       , 'on'      , ...
%     'XColor'      , [.3 .3 .3], ...
%     'YColor'      , [.3 .3 .3], ...

if ~isempty(errors)
    for i = 1:length(yData)
        if isscalar(yData{i})
            hE1 = hline(yData{i}+errors{i});
            hE2 = hline(yData{i}-errors{i});
        else
            if length(yData{i}) >= length(xData)
                if type == 1
                    hE1 = plotFunc(xData,yData{i}(1:length(xData))+errors{i}(1:length(xData)));
                    hE2 = plotFunc(xData,yData{i}(1:length(xData))-errors{i}(1:length(xData)));
                end
            end
        end
        set(hE1,'Color',min(1,colors(i,:)+.75),'LineWidth',1);
        set(hE2,'Color',min(1,colors(i,:)+.75),'LineWidth',1);
        if 0
        switch i
            case 2
                set(hE1,'LineStyle','--');
                set(hE2,'LineStyle','--');
            case 3
                set(hE1,'LineStyle','-.');
                set(hE2,'LineStyle','-.');
            case 4
                set(hE1,'LineStyle',':');
                set(hE2,'LineStyle',':');
        end
        else
            set(hE1,'LineStyle','-');
            set(hE2,'LineStyle','-');
        end
        pause;
    end
end

set(gcf, 'PaperPositionMode', 'auto');
print -depsc2 finalPlot1.eps

end

function [] = applyStyle(h,i,colors,doLineStyle,doMarker,lineWidth)
set(h,'Color',colors(i,:),'LineWidth',lineWidth);
if doLineStyle
    switch i
        case 2
            set(h,'LineStyle','--');
        case 3
            set(h,'LineStyle','-.');
        case 4
            set(h,'LineStyle',':');
    end
end
if doMarker
    % MarkerFaceColor
    % MarkerSize
    % MarkerEdgeColor
   switch i
       case 1
           set(h,'Marker','o');
           
       case 2
           set(h,'Marker','s');
       case 3
           set(h,'Marker','d');
       case 4
           %set(h,'LineStyle','--');
           set(h,'Marker','v');
   end
   set(h,'MarkerSize',10);
   set(h,'MarkerFaceColor',[1 1 .9]);
   %set(h,'MarkerFaceColor',min(colors(i,:)+.75,1));
end
end