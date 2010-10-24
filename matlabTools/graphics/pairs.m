function  pairs(X,vnames,plotsymbol,diagonal)
% PURPOSE: Pairwise scatter plots of the columns of x
%---------------------------------------------------
% USAGE:    pscatter(x,vnames,pltsym,diagon)
%        or pscatter(x) which relies on defaults
% where:  
%        x = an nxk matrix with columns containing variables
%   vnames = a cell array of variable names
%            (default = numeric labels 1,2,3 etc.)
%   pltsym = a plt symbol 
%            (default = '.' for npts > 100, 'o' for npts < 100 
%   diagon = 1 for upper triangle, 2 for lower triangle
%            (default = both upper and lower)
%---------------------------------------------------
% NOTE: uses function histo() 
%---------------------------------------------------

% This file is from pmtk3.googlecode.com


%PMTKauthor Anders Holtsberg
%PMTKdate  14-12-94
%PMTKmodified Kevin Murphy

% JP LeSage added the vnames capability
% Kevin Murphy changed vnames to be cell array (1 March 2007)
% From http://www.spatial-econometrics.com/

clf;
[n,p] = size(X);
X = X - ones(n,1)*min(X);
X = X ./ (ones(n,1)*max(X));

nflag = 0;
if nargin >=2
nflag = 1;
end;

if nargin<4
   diagonal = 0;
end
if nargin<3
   if n*p<100, plotsymbol = 'o';
   else plotsymbol = '.';
   end
end
bf = 0.1;
ffs = 0.05/(p-1);
ffl = (1-2*bf-0.05)/p;
fL = linspace(bf,1-bf+ffs,p+1);
for i = 1:p
   for j = 1:p
      if diagonal == 0 | (diagonal == 1 & j<=i) | (diagonal == 2 & j>=i)
         h = axes('position',[fL(i),fL(p+1-j),ffl,ffl]);
         if i==j
            histo(X(:,i))
            set(gca,'XLim',[-0.1 1.1])
         else
            plot(X(:,i),X(:,j),plotsymbol)
            axis([-0.1 1.1 -0.1 1.1])
         end
         set(gca,'XTickLabel',[],'XTick',[]);
         set(gca,'YTickLabel',[],'YTick',[]);
         if nflag == 1
         set(gca,'fontsize',9);
         end;
         if i==1
            if nflag == 1
            %ylabel(vnames(j,:),'Rotation',90);
	    ylabel(vnames{j},'Rotation',90);
            else
            ylabel([num2str(j),' '],'Rotation',90)
            end;
         end
         if j==1
            if nflag == 1
	      title(vnames{i});
            else
	      title(num2str(i))
            end;
         end
         drawnow
      end
   end
end

