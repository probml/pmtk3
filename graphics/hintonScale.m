function []  = hintonScaleSingle(X, W, varargin)
  % hintonDiagram, where X encodes color, and W encodes size of box
  % If X is NaN, size is empty
  
  %#author Cody Severinski
  
  if nargin < 2 || isempty(W)
      W = NaN*ones(size(X));
  end
    
  Xmin = min(X(:)); Xmax = max(X(:));
  Smin = Xmin*0.95; Smax = Xmax*1.05;
  [map, plotTitle] = processArgs(varargin, '-map', 'Jet', '-title', '');
  C = colormap(map);
  [ncolors] = size(C,1);
  transform = @(x)(fix((x-Xmin)/(Xmax-Xmin)*(ncolors-1))+1);

  % DEFINE BOX EDGES
  xn1 = [-1 -1 +1]*0.5;
  xn2 = [+1 +1 -1]*0.5;
  yn1 = [+1 -1 -1]*0.5;
  yn2 = [-1 +1 +1]*0.5;
  
  xn = [-1 -1 +1 +1 -1]*0.5;
  yn = [-1 +1 +1 -1 -1]*0.5;
  
  [S,R] = size(W);
  
  %cla reset
  hold on;
  set(gca, 'Position', [0.16    0.10    0.75    0.78]);
  set(gca,'xlim',[0 R]+0.5);
  set(gca,'ylim',[0 S]+0.5);
  set(gca,'xlimmode','manual');
  set(gca,'ylimmode','manual');
  xticks = get(gca,'xtick');
  set(gca,'xtick',xticks(find(xticks == floor(xticks))))
  yticks = get(gca,'ytick');
  set(gca,'ytick',yticks(find(yticks == floor(yticks))))
  set(gca,'ydir','reverse');

  m = ((abs(W) - Smin) / (Smax - Smin));
  for i=1:S
    for j=1:R
      if (isfinite(m(i,j)))%real(m(i,j))
        fill(xn*m(i,j)+j,yn*m(i,j)+i,C(transform(X(i,j)),:));
        plot(xn1*m(i,j)+j,yn1*m(i,j)+i,'w',xn2*m(i,j)+j,yn2*m(i,j)+i,'k')
      elseif(~isfinite(m(i,j)) && isfinite(X(i,j)))
        fill(xn+j,yn+i,C(transform(X(i,j)),:));
        plot(xn1+j,yn1+i,'w',xn2+j,yn2+i,'k')
      end
    end
  end
  
  plot([0 R R 0 0]+0.5,[0 0 S S 0]+0.5,'w');
  grid on;
  title(plotTitle);

  msize = @(m)((abs(m) - Smin) / (Smax - Smin));
  breaks = 0.05:0.20:0.85;
  breaksX = (breaks)/R;
  breaksY = (breaks)/S;
  yloc = 0.01 + cumsum(0.15*ones(numel(breaksX),1));
  plotSize = get(gca,'Position');
  scaleY = plotSize(4);
  scaleX = plotSize(3);
  for s=1:length(breaksX)
      location = [0.01, yloc(s), breaksX(s)*scaleX, breaksY(s)*scaleY];
      annotation('rectangle', location, 'color', 'k');
      annotation('textbox', location + [-0.01, 0.05, 0, 0], 'String', sprintf('%3.2f', breaks(s)*(Smax - Smin) + Smin), 'LineStyle', 'none');
  end
  annotation('textbox', [0.00, 0.99, 0.20, 0], 'String', 'Abs(Weight)', 'LineStyle', 'none');
  annotation('textbox', [0.90, 0.99, 0.20, 0], 'String', 'Value', 'LineStyle', 'none');
  % if(allSameMap)
    axes('Position', [0.825 0.1 0.15 0.8], 'Visible', 'off');
    caxis([Xmin, Xmax]);
    colormap(map);
    colorbar;


end