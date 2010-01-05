function plot_errorbars(means,stderrs,rownames)
% plot_errorbars(means,stderrs,rownames)
% makes a plot where each mean is displayed on a row labelled with its
% rowname and a horizontal line connecting (mean-stderr,mean+stderr)

n = size(means,1);
h=plot(means,1:n,'o');
set(h,'linewidth',2)
x = zeros(2,n);
x(1,:) = means-stderrs;
x(2,:) = means+stderrs;
y = repmat(1:n,2,1);
h = line(x,y);
set_linespec(h,'b-');
set(h,'linewidth',2)
axis_pct
set(gca,'ytick',1:n,'yticklabel',rownames,'ydir','reverse')
set(gca,'tickdir','out')
