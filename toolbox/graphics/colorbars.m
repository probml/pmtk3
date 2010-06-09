function colorbars(barGraphHandle,indices,color) 
% set elements of a bar graph to specified color
% eg x = -2.9:0.2:2.9; h = bar(x,exp(-x.*x)); colorbars(h,10:15,'r')

child = get(barGraphHandle, 'Children');
xdata = get(child, 'XData');
ydata = get(child, 'YData');
changeX = xdata(:,indices);
changeY = ydata(:,indices);
patch(changeX,changeY,color);
end