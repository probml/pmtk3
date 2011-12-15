%% Plot 2d sigmoid functions for various values of w1, w2.
% i.e. sigmoid(w1*x1 +%w2*x2)
%%

% This file is from pmtk3.googlecode.com

function sigmoidplot2D


% Plot sigmoids with these parameters
w_1 = [-2 ; -2 ; 0 ; 1 ; 1 ; 2 ;  2 ; 3 ; 5 ; 5];
w_2 = [-1 ;  3 ; 2 ; 4 ; 0 ; 2 ; -2 ; 0 ; 4 ; 1];

lowRes = 0;     % Set to 1 for black and white printing
fullscreen = 1; % Set to 1 to enlarge figure window

left   = min(w_1)-2;   right = max(w_1)+2;
bottom = min(w_2)-2;   top   = max(w_2)+2;

mainFig = setupMainFig;
main_axes = gca;
px = @(x)getX(main_axes,left,right,x); 
py = @(y)getY(main_axes,bottom,top,y);
annotate;

for i=1:length(w_1)
    plotSig(w_1(i),w_2(i),mainFig);    
end
if lowRes
  printPmtkFigure('sigmoidPlot2dColor');
else
   printPmtkFigure('sigmoidPlot2dBW');
end

%%
% Plot a single 2d sigmoid with specified values for w1, w2 to the
% specified figure, 'fig' at relative position, (w1,w2)
function plotSig(w1,w2,fig)
    imageSize = 0.1;
    ax = axes('Parent',fig,'Position',[px(w1), py(w2), imageSize, imageSize],'FontSize',8);
    sig = @(x1,x2)sigmoid(x1.*w1 + x2.*w2);
    stepSize = 0.1; % Decrease to increase image resolution, ( < 0.05 takes up a lot of memory )
    if(lowRes)
        stepSize = 1.2;
    end
    [x1, x2] = meshgrid(-10:stepSize:10,-10:stepSize:10); 
    [rows cols] = size(x1);
    z = sig(x1(:),x2(:));
    z = reshape(z,rows,cols);
    if(lowRes)
        surf(x1,x2,z,'Parent',ax,'LineWidth',0.5,'FaceColor',[1 1 1],'EdgeColor',[0 0 0]);
    else
        %surfl(x1,x2,z,'FaceColor','interp','EdgeColor','interp'); % baback
        surfl(x1,x2,z);                     % baback add
        colormap(gray), shading interp      % baback add
    end
    view([45 25]);  %view([45 35]); % baback change
    xlabel('x_1','FontSize',8,'HorizontalAlignment','right');
    ylabel('x_2','FontSize',8,'HorizontalAlignment','left');
    axis([-10,10,-10,10,0,1]);
    title(['W = ( ', num2str(w1),' , ',num2str(w2),' )'],'FontWeight','bold','FontSize',10);
end
%%
%Convert from a relative x position within the axes to an absolute position
%within the figure. Specify the axes by 'ax', the min and max x values
%within the axes and the relative position, 'xpos' you wish to convert to
%an absolute position. 
function xabs = getX(ax,xmin,xmax,xpos)
    xscale = xmax - xmin;
    axAbs = get(ax,'Position');
    xabs = axAbs(1) + ((xpos-xmin) ./ xscale).*axAbs(3);
end

%see getX
function yabs = getY(ax,ymin,ymax,ypos)
    yscale = ymax - ymin;
    axAbs = get(ax,'Position');
    yabs = axAbs(2) + ((ypos-ymin) ./ yscale).*axAbs(4);
end
%%
% Setup the main figure
function fig = setupMainFig
    close all;
    scrsz = get(0,'ScreenSize');
    if(fullscreen)
        fig = figure('Position',[20 50 9*scrsz(3)/10 8*scrsz(4)/10]);
    else
        fig = figure;
    end
    axis([left,right,bottom,top]);
    set(gca,'XTick',left+1:right-1);
    set(gca,'YTick',bottom+1:top-1);
    hold on;
end
%%
% Add arrows and labels
function annotate
    annotation(mainFig,'arrow',[px(left+1),px(right-1)],[py(0),py(0)],'LineWidth',1.5);
    annotation(mainFig,'arrow',[px(0), px(0)],[py(bottom+1),py(top-1)],'LineWidth',1.5);
    annotation(mainFig,'textbox','String',{'w_1'},'FontWeight','bold','FontSize',12,'FontName','Arial','FitHeightToText','off','LineStyle','none','Position',[px(right-1.5) py(-0.5) 0.04 0.04]);
    annotation(mainFig,'textbox','String',{'w_2'},'FontWeight','bold','FontSize',12,'FontName','Arial','FitHeightToText','off','LineStyle','none','Position',[px(-0.4) py(top-1.5) 0.04 0.04]);
end

end
