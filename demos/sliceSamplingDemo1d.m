% Slice sampling in 1d
% From http://www.mathworks.com/help/toolbox/stats/slicesample.html

requireStatsToolbox();
setSeed(0);
f = @(x) exp( -x.^2/2).*(1+(sin(3*x)).^2).* ...
    (1+(cos(5*x).^2));        
x = slicesample(1,2000,'pdf',f,'thin',5,'burnin',1000); 
hist(x,50)
set(get(gca,'child'),'facecolor',[0.8 .8 1]);
hold on 
xd = get(gca,'XLim'); % Gets the xdata of the bins
binwidth = (xd(2)-xd(1)); % Finds the width of each bin
% Use linspace to normalize the histogram
y = 5.6398*binwidth*f(linspace(xd(1),xd(2),1000));
plot(linspace(xd(1),xd(2),1000),y,'r','LineWidth',2)
printPmtkFigure('sliceSamplingDemo1d')
