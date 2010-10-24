function [] = hintonScale(varargin)
% A modified version of hintonDiagram that allows the user to specify two matrices
% X, W; where X determines the color and W determines the size
% The user can specify two optional arguments
% 'map'   which colormap to use

% This file is from pmtk3.googlecode.com


  if nargin <= 2
    X = varargin{1}{1};
    if(numel(varargin{1}) > 1)
      W = abs(varargin{1}{2});
    else
      W = NaN*ones(size(X));
    end
    nplots = 1;
    Xmin = min(X(:)); Xmax = max(X(:));
    Smin = min(W(:))*0.95; Smax = max(W(:))*1.05;
    if(numel(varargin) > 1)
      if(numel(varargin{2}) == 2)
        [imap, ititle] = process_options(varargin{2}, 'map', 'Jet', 'title', '');
        map{1,:} = imap; plotTitle{1,:} = ititle;
      end
      passargs = varargin{2};
      hintonScaleSingle(X, W, passargs{:});
    else
      hintonScaleSingle(X, W);
    end
    return;
  end
  %[map] = processOptions(varargin, 'map', 'Jet');
  if(nargin > 2)
    nplots = nargin / 2; if(round(nplots) ~= nplots), nplots = 1; end;
    localMinX = zeros(nplots,1); localMaxX = zeros(nplots,1);
    localMinW = zeros(nplots,1); localMaxW = zeros(nplots,1);
    for i=1:nplots
      [imap, ititle] = process_options(varargin{2*i}, 'map', 'Jet', 'title', '');
      map{i,:} = imap; plotTitle{i,:} = ititle;
      allX{i} = varargin{2*i-1}{1};
      localMinX(i) = min(min(allX{i})); localMaxX(i) = max(max(allX{i}));
      if(numel(varargin{2*i-1}) > 1)
        allW{i} = abs(varargin{2*i-1}{2});
      else
        allW{i} = NaN*ones(size(varargin{2*i-1}{1}));
      end
      localMinW(i) = min(min(allW{i})); localMaxW(i) = max(max(allW{i}));
    end
    Xmin = min(localMinX); Xmax = max(localMaxX);
    Smin = min(localMinW)*0.95; Smax = max(localMaxW)*1.05;
  end


  if(size(map,1) > 1)
  allSameMap = all(strcmpi(map{1}, map));
  if(~allSameMap)
    warning('Cannot (yet) support multiple colormaps in subplots.  Using the first');
  end
  end
  C = colormap(map{1,:});
  [ncolors] = size(C,1);
  %transform = @(x)(round(ncolors*(x - Xmin + 1/2)./(Xmax - Xmin + 1/2)));
  transform = @(x)(fix((x-Xmin)/(Xmax-Xmin)*(ncolors-1))+1);

  %map = map{1};



  

  [plotRows,plotCols] = nsubplots(nplots);
  for p=1:nplots
    subplot(plotRows, plotCols, p);
    %if(~allSameMap)
    %  C = colormap(map{p,:});
    %  [ncolors] = size(C,1);
    %  transform = @(x)(round(ncolors*(x - localMinX(p) + 1/2)./(localMaxX(p) - localMinX(p) + 1/2)));
    %end
    if(nplots > 1)
    X = allX{p}; W = allW{p};
    end

    % DEFINE BOX EDGES
    xn1 = [-1 -1 +1]*0.5;
    xn2 = [+1 +1 -1]*0.5;
    yn1 = [+1 -1 -1]*0.5;
    yn2 = [-1 +1 +1]*0.5;
    
    xn = [-1 -1 +1 +1 -1]*0.5;
    yn = [-1 +1 +1 -1 -1]*0.5;
    
    [S,R] = size(W);
    
    %cla reset
    hold on
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
    title(plotTitle{p,:});

    % Not working yet
    %if(~allSameMap)
    %  caxis([localMinX(p), localMaxX(p)]);
    %  colormap(map{p,:});
    %  colorbar;
    %end

  end
    msize = @(m)((abs(m) - Smin) / (Smax - Smin));
    breaks = 0.05:0.20:0.85;
    breaksX = (0.05:0.20:0.85)/R;
    breaksY = (0.05:0.20:0.85)/S;
    yloc = 0.05 + cumsum(0.15*ones(numel(breaksX),1));
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
      axes('Position', [0.85 0.1 0.15 0.8], 'Visible', 'off');
      caxis([Xmin, Xmax]);
      colormap(map{1,:});
      colorbar;
      %colorbar('location', 'SouthOutside');
   % end
end
