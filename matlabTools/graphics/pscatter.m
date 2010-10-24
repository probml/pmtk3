function  pscatter(X,varargin)
% Pairwise scatter plots of the columns of X
% Very similar to plotmatrix in statistics toolbox, but looks prettier
%
% X: n * d matrix of numeric data
% vnames: optional cell array of variable names (default {'1',...,'d'})
% plotsymbol: optional cell array of symbols for each class type,
%      default {'.'} for n>100, {'o'} for  n<100
% y: n*1 optional class labels, default ones(n,1)

% This file is from pmtk3.googlecode.com


%---------------------------------------------------
% NOTE: uses function histo()  and process_options()
%---------------------------------------------------

%PMTKauthor Anders Holtsberg
%PMTKdate December 14, 1994

% JP LeSage added the vnames capability (www.spatial-econometrics.com)
% Kevin Murphy changed vnames to be cell array (1 March 2007),
% and added ability to change the plot symbol for classes (28 December 2007)



[n,p] = size(X);

[vnames, plotsymbol, y] = process_options(...
  varargin, 'vnames', num2cell(int2str((1:p)')), 'plotsymbol', [], ...
  'y', ones(n,1));

nclasses = length(unique(y));
if isempty(plotsymbol)
  if nclasses == 1
    if n*p<100
      plotsymbol{1} = 'o';
    else
      plotsymbol{1} = '.';
    end
  else
    plotsymbol =  {'ro', 'gd', 'b*', 'k+'},
  end
end

   


X = X - ones(n,1)*min(X);
X = X ./ (ones(n,1)*max(X));
bf = 0.1;
ffs = 0.05/(p-1);
ffl = (1-2*bf-0.05)/p;
fL = linspace(bf,1-bf+ffs,p+1);
for i = 1:p
  for j = 1:p
    h = axes('position',[fL(i),fL(p+1-j),ffl,ffl]);
    if i==j
      histo(X(:,i))
      set(gca,'XLim',[-0.1 1.1])
    else
      for c=1:nclasses
        ndx = find(y==c);
        plot(X(ndx,i),X(ndx,j),plotsymbol{c});
        hold on
      end
      axis([-0.1 1.1 -0.1 1.1])
    end
    set(gca,'XTickLabel',[],'XTick',[]);
    set(gca,'YTickLabel',[],'YTick',[]);
    set(gca,'fontsize',9);
    if i==1
      ylabel(vnames{j},'Rotation',90);
    end
    if j==1
      title(vnames{i});
    end
    drawnow
  end
end


end
