%% Create the adjacency graph of a portion of the Web.
% [U,G] = surfer(root,n) starts at the URL root and follows Web links
% until it forms an adjacency graph with n nodes. U = a cell array of n
% strings, the URLs of the nodes. G = an n-by-n sparse matrix with
% G(i,j)=1 if node j is linked to node i.
%
% Example:  [U,G] = surfer('http://www.harvard.edu',500); See also
% PAGERANK.
%
%    This function currently has two defects.  (1) The algorithm for
%    finding links is naive.  We just look for the string 'http:'. (2) An
%    attempt to read from a URL that is accessible, but very slow, might
%    take an unacceptably long time to complete.  In some cases, it may be
%    necessary to have the operating system terminate MATLAB. Key words
%    from such URLs can be added to the skip list in surfer.m.
%%
% PMTKauthor Cleve Moler
% PMTKurl http://www.mathworks.com/moler/ncm/surfer.m
% PMTKinteractive
%%

% This file is from pmtk3.googlecode.com

function [U,G] = surfer(root,n)


% Initialize
if nargin == 0; 
    [U,G] = surfer('http://www.harvard.edu',15);
    return
end

figure
shg
set(gcf,'doublebuffer','on')
axis([0 n 0 n])
axis square
axis ij
box on
set(gca,'position',[.12 .20 .78 .78])
uicontrol('style','frame','units','normal','position',[.01 .09 .98 .07]);
uicontrol('style','frame','units','normal','position',[.01 .01 .98 .07]);
t1 = uicontrol('style','text','units','normal','position',[.02 .10 .94 .04], ...
   'horiz','left');
t2 = uicontrol('style','text','units','normal','position',[.02 .02 .94 .04], ...
   'horiz','left');
slow = uicontrol('style','toggle','units','normal', ...
   'position',[.01 .24 .07 .05],'string','slow','value',0);
quit = uicontrol('style','toggle','units','normal', ...
   'position',[.01 .17 .07 .05],'string','quit','value',0);

U = cell(n,1);
hash = zeros(n,1);
G = logical(sparse(n,n));
m = 1;
U{m} = root;
hash(m) = hashfun(root);

j = 1;
while j < n & get(quit,'value') == 0
   
   % Try to open a page.

   try
      set(t1,'string',sprintf('%5d %s',j,U{j}))
      set(t2,'string','');
      drawnow
      page = urlread(U{j});
   catch
      set(t1,'string',sprintf('fail: %5d %s',j,U{j}))
      drawnow
      continue
   end
   if get(slow,'value')
      pause(.25)
   end

   % Follow the links from the open page.

   for f = findstr('http:',page);

      % A link starts with 'http:' and ends with the next quote.

      e = min([findstr('"',page(f:end)) findstr('''',page(f:end))]);
      if isempty(e), continue, end
      url = deblank(page(f:f+e-2));
      url(url<' ') = '!';   % Nonprintable characters
      if url(end) == '/', url(end) = []; end

      % Look for links that should be skipped.

      skips = {'.gif','.jpg','.pdf','.css','lmscadsi','cybernet', ...
               'search.cgi','.ram','www.w3.org', ...
               'scripts','netscape','shockwave','webex','fansonly'};
      skip = any(url=='!') | any(url=='?');
      k = 0;
      while ~skip & (k < length(skips))
         k = k+1;
         skip = ~isempty(findstr(url,skips{k}));
      end
      if skip
         if isempty(findstr(url,'.gif')) & isempty(findstr(url,'.jpg'))
            set(t2,'string',sprintf('skip: %s',url))
            drawnow
            if get(slow,'value')
               pause(.25)
            end
         end
         continue
      end

      % Check if page is already in url list.

      i = 0;
      for k = find(hash(1:m) == hashfun(url))';
         if isequal(U{k},url)
            i = k;
            break
         end
      end

      % Add a new url to the graph there if are fewer than n.

      if (i == 0) & (m < n)
         m = m+1;
         U{m} = url;
         hash(m) = hashfun(url);
         i = m;
      end

      % Add a new link.

      if i > 0
         G(i,j) = 1;
         set(t2,'string',sprintf('%5d %s',i,url))
         line(j,i,'marker','.','markersize',6)
         drawnow
         if get(slow,'value')
            pause(.25)
         end
      end
   end

   j = j+1;
end
delete(t1)
delete(t2)
delete(slow)
set(quit,'string','close','callback','close(gcf)','value',0)
printPmtkFigure harvard500spy

end
%------------------------

function h = hashfun(url)
% Almost unique numeric hash code for pages already visited.
h = length(url) + 1024*sum(url);

end
