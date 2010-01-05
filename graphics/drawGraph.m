function drawGraph(adj, varargin)
% drawGraph Automatic graph layout: interface to Neato (see http://www.graphviz.org/)
%
% drawGraph(adjMat, ...)  draws a graph in a matlab figure
%
% Optional arguments (string/value pair) [default in brackets]
%
% labels - labels{i} is a *string* for node i [1:n]
% removeSelfLoops - [1]
% removeIsolatedNodes - [1]
% filename - name for postscript file [tmp.ps]
% directed - [default: determine from symmetry of adj] 
% systemFolder - [defaults to location returned by graphvizRoot()]
%
% To set graphvizRoot, add the diectory where dot.exe lives
% to your matlab path, and then store the following lines in a file
% called 'graphvizRoot.m' in the same place:
%  function pathstr = graphvizRoot()
%  [pathstr, name, ext, ver] = fileparts(which('graphvizRoot'));
%
% This function writes files 'tmp.dot' and 'layout.dot'
% to the specified system folder, so you need write permission.
% If this folder is the location where the graphviz executables are,
% it will automatically convert the .dot file to .ps.
% Otherwise you must cd to that directory and type the following at a dos command prompt
%    dot tmp.dot -T ps -o tmp.ps
%
% Example
% 1->2  3  4-5
% adj = zeros(5,5);
% adj(1,2)=1; adj(4,5)=1; adj(5,4)=1;
% adj(1,1) = 1;
% clf;drawGraph(adj)
% clf;drawGraph(adj, 'labels', {'a','bbbb','c','d','e'})
% clf;drawGraph(adj, 'removeIsolatedNodes', 0, 'removeSelfLoops', 0);
%
% Written by Leon Peshkin and Kevin Murphy
% with contributions from  Tom Minka, Alexi Savov
% Contains arrow.m by Erik A. Johnson 
% Contains graph_draw by Ali Taylan Cemgil
% 
% Last updated 7 June 2006
%

if 0
adj = zeros(5,5);
adj(1,2)=1; adj(4,5)=1; adj(5,4)=1;
adj(1,1) = 1;
clf;drawGraph(adj, 'filename', 'foo.ps')
clf;drawGraph(adj)
clf;drawGraph(adj, 'labels', {'a','bbbb','c','d','e'})
clf;drawGraph(adj, 'removeIsolatedNodes', 0, 'removeSelfLoops', 0);
end

if ~exist('graphvizRoot','file')
  systemFolder = [];
  str = sprintf('%s %s %s\n', ...
		'warning: you should put the file graphvizRoot.m', ...
		'into the graphviz/bin directory', ...
		'if you  want to convert to postscript');
  %fprintf(str)
else
  %'C:\Program Files\ATT\Graphviz\bin', ...
  systemFolder = graphvizRoot();
end

[systemFolder, labels, removeSelfLoops, removeIsolatedNodes, filename, directed] = ...
    process_options(varargin, 'systemFolder', systemFolder, ...
		    'labels', [], 'removeSelfLoops', 1, ...
		    'removeIsolatedNodes', 1, 'filename', [], 'directed', []);

if removeSelfLoops
  adj = setdiag(adj, 0); 
end

[n,m] = size(adj);
if n ~= m, warning('not a square adjacency matrix!'); end
%if ~isequal(diag(adj),zeros(n,1)), warning('Self-loops in adjacency matrix!');end

if isempty(labels)
  labels = cell(1,n);
  for i=1:n
    labels{i} = sprintf('%d', i); 
  end
end

if removeIsolatedNodes
  isolated = [];
  for i=1:n
    nbrs = [find(adj(i,:)) find(adj(:,i))'];
    nbrs = setdiff(nbrs, i);
    if isempty(nbrs)
      isolated = [isolated i];
    end
  end
  adj = removeRowsCols(adj, isolated, isolated);
  labels(isolated) = [];
end

if isempty(directed)
  %if isequal(triu(adj ,1),tril(adj,-1)'), directed = 0; else, directed = 1; end 
  if isequal(adj,adj')
    directed = 0;
  else
    directed = 1;
  end
end

adj = double(adj > 0);    % make sure it is a binary matrix cast to double type

% to be platform independant no use of directories in temporary filenames
%tmpDOTfile = '_GtDout.dot';           tmpLAYOUT  = '_LAYout.dot'; 
tmpDOTfile = 'tmp.dot';
tmpLAYOUT = 'layout.dot';

% store graph in tmp.dot
graph_to_dot(adj, 'directed', directed, ...
	     'filename', tmpDOTfile, 'node_label', labels);

if ispc, shell = 'dos'; else, shell = 'unix'; end                %  Which OS ?
cmnd = strcat(shell,'(''neato -V'')');    % request version to check NEATO is there
status = eval(cmnd);
if status == 1,  warning('DOT/NEATO not accessible'); end

%  store layout information in layout.dot
neato = '(''neato -Tdot -Gmaxiter=5000 -Gstart=7 -o'; % -Gstart="regular" -Gregular  
cmnd = strcat([shell neato tmpLAYOUT ' ' tmpDOTfile ''')']);   % -x compact
status = eval(cmnd);                 %  get NEATO to layout

% dot_to_graph fails on isolated vertices
% so instead we just read in the position information from neato 
if 0
  [trash, names, x, y] = dot_to_graph(tmpLAYOUT);   % load NEATO layout
  [ignore,lbl_ndx] = sort(str2num(char(names))');  % recover from dot_to_graph node_ID permutation 
  x = x(lbl_ndx); y = y(lbl_ndx);  
else
  % new labels may not be in 1:1 correspondence with node numbers
  [x, y, newLabels] = readCoordsFromDotFile(tmpLAYOUT, n);
end

% now pick a healthy font size and plot 
if n > 40, fontsz = 7; elseif n < 12, fontsz = 12; else fontsz = 9; end 
%figure; clf;
axis square      %  now plot 
[x, y, h] = graph_draw(adj, 'node_labels', newLabels, 'fontsize', fontsz, ...
                       'node_shapes', zeros(size(x,2),1), 'X', x, 'Y', y);
drawnow
%delete(tmpLAYOUT); delete(tmpDOTfile);   

%%%%%%%%%%%%%%

%%% Now convert .dot to .ps
% This must be run inside the directory where dot.exe lives...

if isempty(systemFolder), return; end

currentDir = pwd;
cd(systemFolder);

try
  graph_to_dot(adj, 'directed', directed, ...
	       'filename', tmpDOTfile, 'node_label', labels);
  
  fprintf('converting to postscript\n');
  % store postscript in tmp.ps - this does not work automatically...
  cmd = sprintf('dot  -Tps tmp.dot -o tmp.ps', shell)
  status = system(cmd)
  %cmnd = strcat(shell,'(''dot -Tps tmp.dot -o tmp.os'')');
  %status = eval(cmnd)
  %!dot -Tps tmp.dot -o tmp.ps
  
  if ~isempty(filename)
    %cmd = sprintf('move tmp.ps %s', fullfile(currentDir,filename))
    cmd = sprintf('move tmp.ps %s', filename);
    system(cmd)
  end
catch
  fprintf('sorry, cant convetr to postscript automatigcally\n');
end
cd(currentDir)

%%%%%%%%%%%%%%%

function graph_to_dot(adj, varargin)

% graph_to_dot(adj, VARARGIN)  Creates a GraphViz (AT&T) format file representing 
%                     a graph given by an adjacency matrix.
%  Optional arguments should be passed as name/value pairs [default]
%
%   'filename'  -  if omitted, writes to 'tmp.dot'
%  'arc_label'  -  arc_label{i,j} is a string attached to the i-j arc [""]
% 'node_label'  -  node_label{i} is a string attached to the node i ["i"]
%  'width'      -  width in inches [10]
%  'height'     -  height in inches [10]
%  'leftright'  -  1 means layout left-to-right, 0 means top-to-bottom [0]
%  'directed'   -  1 means use directed arcs, 0 means undirected [1]
%
% For details on dotty, See http://www.research.att.com/sw/tools/graphviz
%
% by Dr. Leon Peshkin, Jan 2004      inspired by Kevin Murphy's  BNT
%    pesha @ ai.mit.edu /~pesha
                   
node_label = [];   arc_label = [];   % set default args
width = 10;        height = 10;
leftright = 0;     directed = 1;     filename = 'tmp.dot';
           
for i = 1:2:nargin-1              % get optional args
    switch varargin{i}
        case 'filename', filename = varargin{i+1};
        case 'node_label', node_label = varargin{i+1};
        case 'arc_label', arc_label = varargin{i+1};
        case 'width', width = varargin{i+1};
        case 'height', height = varargin{i+1};
        case 'leftright', leftright = varargin{i+1};
        case 'directed', directed = varargin{i+1};
    end
end
fid = fopen(filename, 'w');
if fid==-1
  error(sprintf('could not write to %s', filename))
end
if directed
    fprintf(fid, 'digraph G {\n');
    arctxt = '->'; 
    if isempty(arc_label)
        labeltxt = '';
    else
        labeltxt = '[label="%s"]';
    end
else
    fprintf(fid, 'graph G {\n');
    arctxt = '--'; 
    if isempty(arc_label)
        labeltxt = '[dir=none]';
    else
        labeltext = '[label="%s",dir=none]';
    end
end
fprintf(fid, 'center = 1;\n');
fprintf(fid, 'size=\"%d,%d\";\n', width, height);
if leftright
    fprintf(fid, 'rankdir=LR;\n');
end
Nnds = length(adj);
for node = 1:Nnds               % process NODEs 
    if isempty(node_label)
        fprintf(fid, '%d;\n', node);
    else
        fprintf(fid, '%d [ label = "%s" ];\n', node, node_label{node});
    end
end
edgeformat = strcat(['%d ',arctxt,' %d ',labeltxt,';\n']);
for node1 = 1:Nnds              % process ARCs
    if directed
        arcs = find(adj(node1,:));         % children(adj, node);
    else
        arcs = find(adj(node1,node1+1:Nnds)) + node1; % remove duplicate arcs
    end
    for node2 = arcs
        fprintf(fid, edgeformat, node1, node2);
    end
end
fprintf(fid, '}'); 
fclose(fid);


function [x, y, label] = readCoordsFromDotFile(filename, Nvrt)

% Given a file like this
%
% digraph G {
%       1 [pos="28,31"];
%       2 [pos="74,87"];
%       1 -- 2 [pos="e,61,71 41,47 46,53 50,58 55,64"];
%
% we return x=[28,74], y=[31,87]
% We assume nodes are numbered, not named.
% We assume all the coordinate information comes at the beginning of the file.
% We terminate as soon as we have read coords for Nvrt nodes.
% We do not read the graph structure information.

% KPM 23 May 2006

lines = textread(filename,'%s','delimiter','\n','commentstyle','c'); 
% ignoring C-style comments
dot_lines = strvcat(lines);                                           

if isempty(findstr(dot_lines(1,:), 'graph '))  
   error('* * * File does not appear to be in valid DOT format. * * *');   
end;

x = []; y = []; label = []; % in case there are no nodes...
%x = zeros(1, Nvrt); 
%y = zeros(1, Nvrt);
seenNode = zeros(1, Nvrt);
line_ndx = 1;
done = 0;
while ~done
  if line_ndx > size(dot_lines, 1) | all(seenNode)
    break
  end
  line = dot_lines(line_ndx,:);
  if ~isempty(strfind(line, '->')) | ~isempty(strfind(line, '--'))
    %finished reading location information - quitting
    break
  end
  line_ndx = line_ndx + 1;
  if isempty(strfind(line, 'pos')) % skip header info
    continue;
  end
  str = line;
  %cells =   regexp(str, '(\d+)\s+\[pos="(\d+),(\d+)', 'tokens');
  %cells =   regexp(str, '(\d+)\s+\[label=(\w+), pos="(\d+),(\d+)', 'tokens');
  
  % fixed by David Duvenaud
  cells = regexp(str, '(\d+)\s+\[label=(\w+), pos="(\d+\.?\d+),(\d+\.?\d+)', 'tokens');

  node = str2num(cells{1}{1});
  %label(node) = str2num(cells{1}{2});
  %label{node} = num2str(cells{1}{2});
  label{node} = cells{1}{2};
  xx = str2num(cells{1}{3});
  yy = str2num(cells{1}{4});
  x(node) = xx;
  y(node) = yy;
  %fprintf('n=%d,x=%d,y=%d,%s!\n', node, xx, yy, label{node});
  seenNode(node) = 1;
end


x = .9*(x-min(x))/range(x)+.05;  % normalise and push off margins 
if range(y) == 0, y = .5*ones(size(y)); else, y = .9*(y-min(y))/range(y)+.05; end


%%%%%%%%%%%%

function [Adj, labels, x, y] = dot_to_graph(filename)

% [Adj, labels, x, y] = dot_to_graph(filename)
% Extract an adjacency matrix, node labels, and layout (nodes coordinates) 
% from GraphViz file       http://www.research.att.com/sw/tools/graphviz
%
% INPUT:  'filename' - the file in DOT format containing the graph layout.
% OUTPUT: 'Adj' - an adjacency matrix with sequentially numbered edges; 
%     'labels'  - a character array with the names of the nodes of the graph;
%          'x'  - a row vector with the x-coordinates of the nodes in 'filename';
%          'y'  - a row vector with the y-coordinates of the nodes in 'filename'.
%
% WARNINGS: not guaranted to parse ANY GraphViz file. Debugged on undirected 
%       sample graphs from GraphViz(Heawood, Petersen, ER, ngk10_4, process). 
%       Complaines about RecursionLimit on huge graphs.
%       Ignores singletons (disjoint nodes).         
% Sample DOT code "ABC.dot", read by [Adj, labels, x, y] = dot_to_graph('ABC.dot')
% Plot by    draw_graph(adj>0, labels, zeros(size(x,2),1), x, y);  % from BNT
% digraph G {
%       A [pos="28,31"];
%       B [pos="74,87"];
%       A -- B [pos="e,61,71 41,47 46,53 50,58 55,64"];
% }
%                                                     last modified: Jan 2004
% by Dr. Leon Peshkin: pesha @ ai.mit.edu | http://www.ai.mit.edu/~pesha 
%  & Alexi Savov:  asavov @ wustl.edu |  http://artsci.wustl.edu/~azsavov

       %  UNCOMMENT, but beware -- SLOW CHECK !!!! 
%if ~exist(filename)                % Checks whether the specified file exists.
%   error('* * * File does not exist or could not be found. * * *');     return;
%end;     

lines = textread(filename,'%s','delimiter','\n','commentstyle','c');  % Read file into cell array of lines
dot_lines = strvcat(lines);                                           % ignoring C-style comments

if isempty(findstr(dot_lines(1,:), 'graph '))                  % Is this a DOT file ?
   error('* * * File does not appear to be in valid DOT format. * * *');    return;
end;

Nlns = size(dot_lines,1);             % The number of lines;
labels = {};
unread = 1:Nlns;             % 'unread' list of lines which has not been examined yet
edge_id = 1;
for line_ndx = 1:Nlns          % This section sets the adjacency matrix entry A(Lnode,Rnode) = edge_id.
    line = dot_lines(line_ndx,:);
    Ddash_pos = strfind(line, ' -- ') + 1;  % double dash positions
    arrow_pos = strfind(line, ' -> ') + 1;  % arrow  dash positions
    tokens = strread(line,'%s','delimiter',' "');
    left_bound = 1;
    for dash_pos = [Ddash_pos arrow_pos];  % if empty - not a POS line
        Lnode = sscanf(line(left_bound:dash_pos -2), '%s');
        Rnode = sscanf(line(dash_pos +3 : length(line)-1),'%s',1);
        Lndx = strmatch(Lnode, labels, 'exact');
        Rndx = strmatch(Rnode, labels, 'exact');
        if isempty(Lndx)         % extend our list of labels 
            labels{end+1} = Lnode;
            Lndx = length(labels);
        end
        if isempty(Rndx)
            labels{end+1} = Rnode;
            Rndx = length(labels);
        end
        Adj(Lndx, Rndx) = edge_id;;
        if  ismember(dash_pos, Ddash_pos)  % The edge is undirected, A(Rndx,LndxL) is also set to 1;
            Adj(Rndx, Lndx) = edge_id;
        end
        edge_id = edge_id + 1; 
        left_bound = dash_pos + 3;
        unread = my_setdiff(unread, line_ndx); 
    end
end
Nvrt = length(labels);  % number of vertices we found  [Do we ever have singleton vertices ???]
% labels = strvcat(labels); % could convert to the searchable array
x = zeros(1, Nvrt); 
y = zeros(1, Nvrt);
lst_node = 0;
% Find node's position coordinates if they are contained in 'filename'.
for line_ndx = unread        % Look for node's coordiantes among the 'unread' lines.
    line = dot_lines(line_ndx,:);
    bra_pos  = strfind(line, '[');      % has to have "[" if it has the lable
    pos_pos = strfind(line, 'pos');     % position of the "pos"
    for node = 1:Nvrt     % look through the list of labels 
        %  THE NEXT STATEMENT we assume no label is substring of any other label
        lbl_pos = strfind(line, labels{node});
        if ((~isempty(lbl_pos)) & (~isempty(bra_pos)) & (x(node) == 0))  % make sure we have not seen it 
            if (lbl_pos(1) < bra_pos(1))  % label has to be to the left of braket
                lst_node = node;
            end
        end
    end
    if (~isempty(pos_pos) & lst_node)   % this line contains SOME position  
        [node_pos] = sscanf(line(pos_pos:length(line)), ' pos  = "%d,%d"')';
        x(lst_node) = node_pos(1);
        y(lst_node) = node_pos(2);
        lst_node = 0;   %  not to assign position several times 
    end
end

if (isempty(find(x)) & (nargout > 2))   % If coordinates were requested, but not found in 'filename'.
    warning('File does not contain node coordinates.');
else
    x = .9*(x-min(x))/range(x)+.05;  % normalise and push off margins 
    if range(y) == 0, y = .5*ones(size(y)); else, y = .9*(y-min(y))/range(y)+.05; end
end;
if ~(size(Adj,1)==size(Adj,2))           % Make sure Adj is a square matrix. ? 
    Adj = eye(max(size(Adj)),size(Adj,1))*Adj*eye(size(Adj,2),max(size(Adj)));
end;



%%%%%%%%%%%%%%%%%%%%%

function [x, y, h] = graph_draw(adj, varargin)
%  [x, y, h] = graph_draw(adj, varargin)  
%
% INPUTS:      ADJ   -  Adjacency matrix (source, sink)
%      'linestyle'   -  default '-' 
%      'linewidth'   -  default .5
%      'linecolor'   -  default Black
%      'fontsize'    -  fontsize for labels, default 8 
%      'node_labels' -  Cell array containing labels <Default : '1':'N'>
%      'node_shapes' -  1 if node is a box, 0 if oval <Default : zeros>
%      'X'  Coordinates of nodes on the unit square <Default : calls make_layout>
%      'Y'     
%
% OUTPUT:   x, y   -  Coordinates of nodes on the unit square
%               h  -  Object handles [h(i,1) is the text handle - color
%                                     h(i,2) is the circle handle - facecolor]
%

% Feb 2004  cleaned up, optimized and corrected by Leon Peshkin pesha @ ai.mit.edu 
% Apr-2000  draw_graph   Ali Taylan Cemgil   <cemgil@mbfys.kun.nl> 
% 1995-1997 arrow        Erik A. Johnson     <johnsone@uiuc.edu>

linestyle = '-';       %   --   -. 
linewidth = .5;        %   2 
linecolor = 'Black';   %   Red
fontsize = 8;
N = size(adj,1);
labels = cellstr(int2str((1:N)'));    %  labels = cellstr(char(zeros(N,1)+double('+')));
node_t = zeros(N,1);                  %  
for i = 1:2:nargin-1                  % get optional args
    switch varargin{i}
        case 'linestyle', linestyle = varargin{i+1};
        case 'linewidth', linewidth = varargin{i+1};
        case 'linecolor', linecolor = varargin{i+1};
        case 'node_labels', labels  = varargin{i+1};
        case 'fontsize',  fontsize = varargin{i+1}; 
        case 'node_shapes', node_t  = varargin{i+1};  node_t = node_t(:);
        case 'X', x = varargin{i+1};
        case 'Y', y = varargin{i+1};
    end
end

axis([0 1 0 1]);
set(gca,'XTick',[], 'YTick',[], 'box','on'); % axis('square');   %colormap(flipud(gray));

if (~exist('x','var') | ~exist('x','var'))
     [x y] = make_layout(adj);
end;

idx1 = find(node_t == 0); wd1 = [];
if ~isempty(idx1),
    [h1 wd1] = textoval(x(idx1), y(idx1), labels(idx1), fontsize);
end;

idx2 = find(node_t ~= 0); wd2 = [];
if ~isempty(idx2),
    [h2 wd2] = textbox(x(idx2), y(idx2), labels(idx2));
end;

wd = zeros(size(wd1,1) + size(wd2,1),2);
if ~isempty(idx1), wd(idx1, :) = wd1; end;
if ~isempty(idx2), wd(idx2, :) = wd2; end;

for node = 1:N,
  edges = find(adj(node,:) == 1);
  for node2 = edges
    sign = 1;
    if ((x(node2) - x(node)) == 0)
	    if (y(node) > y(node2)), alpha = -pi/2; else alpha = pi/2; end;
    else
        alpha = atan((y(node2)-y(node))/(x(node2)-x(node)));
	    if (x(node2) <= x(node)), sign = -1; end;
    end;
    dy1 = sign.*wd(node,2).*sin(alpha);   dx1 = sign.*wd(node,1).*cos(alpha);
    dy2 = sign.*wd(node2,2).*sin(alpha);  dx2 = sign.*wd(node2,1).*cos(alpha);    
    if  (adj(node2,node) == 0)           % if directed edge
        my_arrow([x(node)+dx1 y(node)+dy1], [x(node2)-dx2 y(node2)-dy2]);
    else	   
        line([x(node)+dx1 x(node2)-dx2], [y(node)+dy1 y(node2)-dy2], ...
            'Color', linecolor, 'LineStyle', linestyle, 'LineWidth', linewidth);
        adj(node2,node) = -1;         % Prevent drawing lines twice
    end;
  end;
end;

if nargout > 2
    h = zeros(length(wd),2);
    if ~isempty(idx1), h(idx1,:) = h1;   end;
    if ~isempty(idx2), h(idx2,:) = h2;   end;
end;

%%%%%%%%%%%%%%%

function [t, wd] = textoval(x, y, str, fontsize)
%  [t, wd] = textoval(x, y, str, fontsize)    Draws an oval around text objects
% INPUT:   x, y - Coordinates
%           str - Strings
% OUTPUT:     t - Object Handles
%         width - x and y  width of ovals 
temp = [];
if ~isa(str,'cell'), str = cellstr(str); end;
N = length(str);    
wd = zeros(N,2);
for i = 1:N,
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle','FontSize',fontsize);
    sz = get(tx, 'Extent');
    wy = sz(4);
    wx = max(2/3*sz(3), wy); 
    wx = 0.9 * wx;        %  might want to play with this .9 and .5 coefficients 
    wy = 0.5 * wy;
    ptc = ellipse(x(i), y(i), wx, wy);
    set(ptc, 'FaceColor','w');    
    wd(i,:) = [wx wy];
    delete(tx);
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle', 'FontSize',fontsize);      
    temp = [temp;  tx ptc];
end;
t = temp; 

function [p] = ellipse(x, y, rx, ry)
%  [p] = ellipse(x, y, rx, ry)    Draws Ellipse shaped patch objects
% INPUT:  x,y -  N x 1 vectors of x and y coordinates
%    Rx, Ry -   Radii
% OUTPUT: p -   Handles of Ellipse shaped path objects

c = ones(size(x));
  if length(rx)== 1, rx = ones(size(x)).*rx; end;
  if length(ry)== 1, ry = ones(size(x)).*ry; end;
N = length(x);
p = zeros(size(x));
t = 0:pi/30:2*pi;
for i = 1:N
	px = rx(i) * cos(t) + x(i);    py = ry(i) * sin(t) + y(i);
	p(i) = patch(px, py, c(i));
end;

function [h, wd] = textbox(x,y,str)
%  [h, wd] = textbox(x,y,str)    draws a box around the text 
% INPUT:  x, y - Coordinates
%         str  - Strings
% OUTPUT:    h - Object Handles
%           wd - x and y Width of boxes 

h = [];
if ~isa(str,'cell') str=cellstr(str); end;    
N = length(str);
for i = 1:N,
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle');
    sz = get(tx, 'Extent');
    wy = 2/3 * sz(4); wyB = y(i) - wy;  wyT = y(i) + wy;
    wx = max(2/3 * sz(3), wy); wxL = x(i) - wx; wxR = x(i) + wx;
    ptc = patch([wxL wxR wxR wxL], [wyT wyT wyB wyB],'w'); % draw_box(tx, x(i), y(i));
    set(ptc, 'FaceColor','w');
    wd(i,:) = [wx wy];
    delete(tx);
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle');      
    h = [h; tx ptc];
end;

function [h,yy,zz] = my_arrow(varargin)
% [h,yy,zz] = my_arrow(varargin)  Draw a line with an arrowhead.

% A lot of the original code is removed and most of the remaining can probably go too
% since it comes from a general use function only being called inone context. - Leon Peshkin 
% Copyright 1997, Erik A. Johnson <johnsone@uiuc.edu>, 8/14/97

ax         = [];       % set values to empty matrices
deflen        = 12;  %  16
defbaseangle  = 45;  %  90
deftipangle   = 16;
defwid = 0;  defpage = 0;  defends = 1;
ArrowTag = 'Arrow';  % The 'Tag' we'll put on our arrows
start      = varargin{1};    % fill empty arguments
stop       = varargin{2}; 
crossdir   = [NaN NaN NaN];   
len        = NaN; baseangle  = NaN;  tipangle = NaN;   wid = NaN;              
page       = 0; ends  = NaN;   
start = [start NaN];   stop = [stop NaN];
o         = 1;     % expand single-column arguments
ax        = gca;
% set up the UserData data (here so not corrupted by log10's and such)
ud = [start stop len baseangle tipangle wid page crossdir ends];
% Get axes limits, range, min; correct for aspect ratio and log scale
axm  = zeros(3,1);   axr = axm;   axrev = axm;  ap  = zeros(2,1);
xyzlog = axm; limmin    = ap;  limrange  = ap;  oldaxlims = zeros(1,7);
oneax = 1;      % all(ax==ax(1));  LPM
if (oneax),
	T = zeros(4,4); invT = zeros(4,4);
else
	T = zeros(16,1); invT = zeros(16,1); end
axnotdone = 1; % logical(ones(size(ax)));  LPM 
while (any(axnotdone)),
	ii = 1;  % LPM min(find(axnotdone));
	curax = ax(ii);
	curpage = page(ii);
	% get axes limits and aspect ratio
	axl = [get(curax,'XLim'); get(curax,'YLim'); get(curax,'ZLim')];
	oldaxlims(min(find(oldaxlims(:,1)==0)),:) = [curax reshape(axl',1,6)];
	% get axes size in pixels (points)
	u = get(curax,'Units');
	axposoldunits = get(curax,'Position');
	really_curpage = curpage & strcmp(u,'normalized');
	if (really_curpage),
		curfig = get(curax,'Parent');  		pu = get(curfig,'PaperUnits');
		set(curfig,'PaperUnits','points');  pp = get(curfig,'PaperPosition');
		set(curfig,'PaperUnits',pu);         set(curax,'Units','pixels');
		curapscreen = get(curax,'Position'); set(curax,'Units','normalized');
		curap = pp.*get(curax,'Position');
	else,
		set(curax,'Units','pixels');
		curapscreen = get(curax,'Position');
		curap = curapscreen;
	end;
	set(curax,'Units',u);      set(curax,'Position',axposoldunits);
	% handle non-stretched axes position
	str_stretch = {'DataAspectRatioMode'; 'PlotBoxAspectRatioMode' ; 'CameraViewAngleMode' };
	str_camera  = {'CameraPositionMode'  ; 'CameraTargetMode' ; ...
	                'CameraViewAngleMode' ; 'CameraUpVectorMode'};
	notstretched = strcmp(get(curax,str_stretch),'manual');
	manualcamera = strcmp(get(curax,str_camera),'manual');
	if ~arrow_WarpToFill(notstretched,manualcamera,curax),
		% find the true pixel size of the actual axes
		texttmp = text(axl(1,[1 2 2 1 1 2 2 1]), ...
		               axl(2,[1 1 2 2 1 1 2 2]), axl(3,[1 1 1 1 2 2 2 2]),'');
		set(texttmp,'Units','points');
		textpos = get(texttmp,'Position');
		delete(texttmp);
		textpos = cat(1,textpos{:});
		textpos = max(textpos(:,1:2)) - min(textpos(:,1:2));
		% adjust the axes position
		if (really_curpage),  			% adjust to printed size
			textpos = textpos * min(curap(3:4)./textpos);
			curap = [curap(1:2)+(curap(3:4)-textpos)/2 textpos];
		else,                        % adjust for pixel roundoff
			textpos = textpos * min(curapscreen(3:4)./textpos);
			curap = [curap(1:2)+(curap(3:4)-textpos)/2 textpos];
		end;
	end;
	% adjust limits for log scale on axes
	curxyzlog = [strcmp(get(curax,'XScale'),'log'); ...
	             strcmp(get(curax,'YScale'),'log'); strcmp(get(curax,'ZScale'),'log')];
	if (any(curxyzlog)),
		ii = find([curxyzlog;curxyzlog]);
		if (any(axl(ii)<=0)),
			error([upper(mfilename) ' does not support non-positive limits on log-scaled axes.']);
		else,
			axl(ii) = log10(axl(ii));
		end;
	end;
	% correct for 'reverse' direction on axes;
	curreverse = [strcmp(get(curax,'XDir'),'reverse'); ...
	              strcmp(get(curax,'YDir'),'reverse'); strcmp(get(curax,'ZDir'),'reverse')];
	ii = find(curreverse);
	if ~isempty(ii),
		axl(ii,[1 2])=-axl(ii,[2 1]);
	end;
	% compute the range of 2-D values
	curT = get(curax,'Xform');
	lim = curT*[0 1 0 1 0 1 0 1;0 0 1 1 0 0 1 1;0 0 0 0 1 1 1 1;1 1 1 1 1 1 1 1];
	lim = lim(1:2,:)./([1;1]*lim(4,:));
	curlimmin = min(lim')';
	curlimrange = max(lim')' - curlimmin;
	curinvT = inv(curT);
	if (~oneax),
		curT = curT.'; curinvT = curinvT.'; curT = curT(:); curinvT = curinvT(:);
	end;
	% check which arrows to which cur corresponds
	ii = find((ax==curax)&(page==curpage));
	oo = ones(1,length(ii)); 	axr(:,ii) = diff(axl')' * oo;
	axm(:,ii) = axl(:,1) * oo;  axrev(:,ii) = curreverse  * oo;
	ap(:,ii)  = curap(3:4)' * oo; xyzlog(:,ii) = curxyzlog   * oo;
	limmin(:,ii) = curlimmin  * oo;  limrange(:,ii) = curlimrange * oo;
	if (oneax),
		T    = curT;  invT = curinvT;
	else,
		T(:,ii) = curT * oo; invT(:,ii) = curinvT * oo;
	end;
	axnotdone(ii) = zeros(1,length(ii));
end;
oldaxlims(oldaxlims(:,1)==0,:) = [];

% correct for log scales
curxyzlog = xyzlog.';  ii = find(curxyzlog(:));
if ~isempty(ii),
	start(ii) = real(log10(start(ii))); stop(ii) = real(log10(stop(ii)));
	if (all(imag(crossdir)==0)), % pulled (ii) subscript on crossdir, 12/5/96 eaj
		crossdir(ii) = real(log10(crossdir(ii)));
	end;
end;
ii = find(axrev.');    % correct for reverse directions
if ~isempty(ii),
	start(ii) = -start(ii);  stop(ii) = -stop(ii); crossdir(ii) = -crossdir(ii);
end;
start  = start.';  stop  = stop.';   % transpose start/stop values
% take care of defaults, page was done above
ii = find(isnan(start(:)));  if ~isempty(ii),  start(ii) = axm(ii)+axr(ii)/2;  end;
ii = find(isnan(stop(:)));  if ~isempty(ii),  stop(ii) = axm(ii)+axr(ii)/2;  end;
ii = find(isnan(crossdir(:))); if ~isempty(ii),  crossdir(ii) = zeros(length(ii),1); end;
ii = find(isnan(len));  if ~isempty(ii),  len(ii) = ones(length(ii),1)*deflen; end;
baseangle(ii) = ones(length(ii),1)*defbaseangle;  tipangle(ii) = ones(length(ii),1)*deftipangle; 
wid(ii) = ones(length(ii),1) * defwid;   ends(ii) = ones(length(ii),1) * defends;
% transpose rest of values
len  = len.';  baseangle = baseangle.'; tipangle  = tipangle.'; wid = wid.';  
page = page.'; crossdir  = crossdir.';  ends = ends.'; ax   = ax.';

% for all points with start==stop, start=stop-(verysmallvalue)*(up-direction);
ii = find(all(start==stop));
if ~isempty(ii),
	% find an arrowdir vertical on screen and perpendicular to viewer
	%	transform to 2-D
		tmp1 = [(stop(:,ii)-axm(:,ii))./axr(:,ii);ones(1,length(ii))];
		if (oneax), twoD=T*tmp1;
		else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=T(:,ii).*tmp1;
		      tmp2=zeros(4,4*length(ii)); tmp2(:)=tmp1(:);
		      twoD=zeros(4,length(ii)); twoD(:)=sum(tmp2)'; end;
		twoD=twoD./(ones(4,1)*twoD(4,:));
	%	move the start point down just slightly
		tmp1 = twoD + [0;-1/1000;0;0]*(limrange(2,ii)./ap(2,ii));
	%	transform back to 3-D
		if (oneax), threeD=invT*tmp1;
		else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=invT(:,ii).*tmp1;
		      tmp2=zeros(4,4*length(ii)); tmp2(:)=tmp1(:);
		      threeD=zeros(4,length(ii)); threeD(:)=sum(tmp2)'; end;
		start(:,ii) = (threeD(1:3,:)./(ones(3,1)*threeD(4,:))).*axr(:,ii)+axm(:,ii);
end;
% compute along-arrow points
%	transform Start points
	tmp1 = [(start-axm)./axr; 1];
	if (oneax), X0=T*tmp1;
	else, tmp1 = [tmp1;tmp1;tmp1;tmp1]; tmp1=T.*tmp1;
	      tmp2 = zeros(4,4); tmp2(:)=tmp1(:);
	      X0=zeros(4,1); X0(:)=sum(tmp2)'; end;
	X0=X0./(ones(4,1)*X0(4,:));
%	transform Stop points
	tmp1=[(stop-axm)./axr; 1];
	if (oneax), Xf=T*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=T.*tmp1;
	      tmp2=zeros(4,4); tmp2(:)=tmp1(:);
	      Xf=zeros(4,1); Xf(:)=sum(tmp2)'; end;
	Xf=Xf./(ones(4,1)*Xf(4,:));
%	compute pixel distance between points
	D = sqrt(sum(((Xf(1:2,:)-X0(1:2,:)).*(ap./limrange)).^2));
%	compute and modify along-arrow distances
	len1 = len;
	len2 = len - (len.*tan(tipangle/180*pi)-wid/2).*tan((90-baseangle)/180*pi);
	slen0 = 0; 	slen1 = len1 .* ((ends==2)|(ends==3));
	slen2 = len2 .* ((ends==2)|(ends==3));
	len0 = 0; len1  = len1 .* ((ends==1)|(ends==3));
	len2  = len2 .* ((ends==1)|(ends==3));
      ii = find((ends==1)&(D<len2));  	%	for no start arrowhead
	  if ~isempty(ii),
		  slen0(ii) = D(ii)-len2(ii);
	  end;
	  ii = find((ends==2)&(D<slen2));  	%	for no end arrowhead
	  if ~isempty(ii),
		  len0(ii) = D(ii)-slen2(ii);
	  end;
	len1  = len1  + len0;    len2 = len2  + len0;
	slen1 = slen1 + slen0; 	slen2 = slen2 + slen0;
 	% note:  the division by D below will probably not be accurate if both
 	%        of the following are true:
 	%           1. the ratio of the line length to the arrowhead
 	%              length is large
 	%           2. the view is highly perspective.
%	compute stoppoints
	tmp1 = X0.*(ones(4,1)*(len0./D))+Xf.*(ones(4,1)*(1-len0./D));
	if (oneax), tmp3 = invT*tmp1;
	else, tmp1 = [tmp1;tmp1;tmp1;tmp1]; tmp1 = invT.*tmp1;
	      tmp2 = zeros(4,4); tmp2(:) = tmp1(:);
	      tmp3 = zeros(4,1); tmp3(:) = sum(tmp2)'; end;
	stoppoint = tmp3(1:3,:)./(ones(3,1)*tmp3(4,:)).*axr+axm;
%	compute tippoints
	tmp1=X0.*(ones(4,1)*(len1./D))+Xf.*(ones(4,1)*(1-len1./D));
	if (oneax), tmp3=invT*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=invT.*tmp1;
	      tmp2=zeros(4,4); tmp2(:)=tmp1(:);
	      tmp3=zeros(4,1); tmp3(:)=sum(tmp2)'; end;
	tippoint = tmp3(1:3,:)./(ones(3,1)*tmp3(4,:)).*axr+axm;
%	compute basepoints
	tmp1=X0.*(ones(4,1)*(len2./D))+Xf.*(ones(4,1)*(1-len2./D));
	if (oneax), tmp3=invT*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=invT.*tmp1;
	      tmp2=zeros(4,4); tmp2(:)=tmp1(:);
	      tmp3=zeros(4,1); tmp3(:)=sum(tmp2)'; end;
	basepoint = tmp3(1:3,:)./(ones(3,1)*tmp3(4,:)).*axr+axm;
%	compute startpoints
	tmp1=X0.*(ones(4,1)*(1-slen0./D))+Xf.*(ones(4,1)*(slen0./D));
	if (oneax), tmp3=invT*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=invT.*tmp1;
	      tmp2=zeros(4,4); tmp2(:) = tmp1(:);
	      tmp3=zeros(4,1); tmp3(:) = sum(tmp2)'; end;
	startpoint = tmp3(1:3,:)./(ones(3,1)*tmp3(4,:)).*axr+axm;
%	compute stippoints
	tmp1=X0.*(ones(4,1)*(1-slen1./D))+Xf.*(ones(4,1)*(slen1./D));
	if (oneax), tmp3=invT*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1 = invT.*tmp1;
	      tmp2=zeros(4,4); tmp2(:)=tmp1(:); 
	      tmp3=zeros(4,1); tmp3(:)=sum(tmp2)'; end;
	stippoint = tmp3(1:3,:)./(ones(3,1)*tmp3(4,:)).*axr+axm;
%	compute sbasepoints
	tmp1=X0.*(ones(4,1)*(1-slen2./D))+Xf.*(ones(4,1)*(slen2./D));
	if (oneax), tmp3=invT*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=invT.*tmp1;
	      tmp2=zeros(4,4); tmp2(:)=tmp1(:);
	      tmp3=zeros(4,1); tmp3(:)=sum(tmp2)'; end;
	sbasepoint = tmp3(1:3,:)./(ones(3,1)*tmp3(4,:)).*axr+axm;

% compute cross-arrow directions for arrows with NormalDir specified
if (any(imag(crossdir(:))~=0)),
	ii = find(any(imag(crossdir)~=0));
	crossdir(:,ii) = cross((stop(:,ii)-start(:,ii))./axr(:,ii), ...
	                       imag(crossdir(:,ii))).*axr(:,ii);
end;
basecross  = crossdir + basepoint;  % compute cross-arrow directions
tipcross   = crossdir + tippoint;  sbasecross = crossdir + sbasepoint;
stipcross  = crossdir + stippoint;
ii = find(all(crossdir==0)|any(isnan(crossdir)));
if ~isempty(ii),
	numii = length(ii);
	%	transform start points
		tmp1 = [basepoint(:,ii) tippoint(:,ii) sbasepoint(:,ii) stippoint(:,ii)];
		tmp1 = (tmp1-axm(:,[ii ii ii ii])) ./ axr(:,[ii ii ii ii]);
		tmp1 = [tmp1; ones(1,4*numii)];
		if (oneax), X0=T*tmp1;
		else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=T(:,[ii ii ii ii]).*tmp1;
		      tmp2=zeros(4,16*numii); tmp2(:)=tmp1(:);
		      X0=zeros(4,4*numii); X0(:)=sum(tmp2)'; end;
		X0=X0./(ones(4,1)*X0(4,:));
	%	transform stop points
		tmp1 = [(2*stop(:,ii)-start(:,ii)-axm(:,ii))./axr(:,ii);ones(1,numii)];
		tmp1 = [tmp1 tmp1 tmp1 tmp1];
		if (oneax), Xf=T*tmp1;
		else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=T(:,[ii ii ii ii]).*tmp1;
		      tmp2=zeros(4,16*numii); tmp2(:)=tmp1(:);
		      Xf=zeros(4,4*numii); Xf(:)=sum(tmp2)'; end;
		Xf=Xf./(ones(4,1)*Xf(4,:));
	%	compute perpendicular directions
		pixfact = ((limrange(1,ii)./limrange(2,ii)).*(ap(2,ii)./ap(1,ii))).^2;
		pixfact = [pixfact pixfact pixfact pixfact];
		pixfact = [pixfact;1./pixfact];
		[dummyval,jj] = max(abs(Xf(1:2,:)-X0(1:2,:)));
		jj1 = ((1:4)'*ones(1,length(jj))==ones(4,1)*jj);
		jj2 = ((1:4)'*ones(1,length(jj))==ones(4,1)*(3-jj));
		jj3 = jj1(1:2,:);
		Xp = X0;
		Xp(jj2) = X0(jj2) + ones(sum(jj2(:)),1);
		Xp(jj1) = X0(jj1) - (Xf(jj2)-X0(jj2))./(Xf(jj1)-X0(jj1)) .* pixfact(jj3);
	%	inverse transform the cross points
		if (oneax), Xp=invT*Xp;
		else, tmp1=[Xp;Xp;Xp;Xp]; tmp1=invT(:,[ii ii ii ii]).*tmp1;
		      tmp2=zeros(4,16*numii); tmp2(:)=tmp1(:);
		      Xp=zeros(4,4*numii); Xp(:)=sum(tmp2)'; end;
		Xp=(Xp(1:3,:)./(ones(3,1)*Xp(4,:))).*axr(:,[ii ii ii ii])+axm(:,[ii ii ii ii]);
		basecross(:,ii)  = Xp(:,0*numii+(1:numii));
		tipcross(:,ii)   = Xp(:,1*numii+(1:numii));
		sbasecross(:,ii) = Xp(:,2*numii+(1:numii));
		stipcross(:,ii)  = Xp(:,3*numii+(1:numii));
end;

% compute all points
%	compute start points
	axm11 = [axm axm axm axm axm axm axm axm axm axm axm];
	axr11 = [axr axr axr axr axr axr axr axr axr axr axr];
	st = [stoppoint tippoint basepoint sbasepoint stippoint startpoint stippoint sbasepoint basepoint tippoint stoppoint];
	tmp1 = (st - axm11) ./ axr11;
	tmp1 = [tmp1; ones(1,size(tmp1,2))];
	if (oneax), X0=T*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=[T T T T T T T T T T T].*tmp1;
	      tmp2=zeros(4,44); tmp2(:)=tmp1(:);
	      X0=zeros(4,11); X0(:)=sum(tmp2)'; end;
	X0=X0./(ones(4,1)*X0(4,:));
%	compute stop points
	tmp1 = ([start tipcross basecross sbasecross stipcross stop stipcross sbasecross basecross tipcross start] ...
	     - axm11) ./ axr11;
	tmp1 = [tmp1; ones(1,size(tmp1,2))];
	if (oneax), Xf=T*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=[T T T T T T T T T T T].*tmp1;
	      tmp2=zeros(4,44); tmp2(:)=tmp1(:);
	      Xf=zeros(4,11); Xf(:)=sum(tmp2)'; end;
	Xf=Xf./(ones(4,1)*Xf(4,:));
%	compute lengths
	len0  = len.*((ends==1)|(ends==3)).*tan(tipangle/180*pi);
	slen0 = len.*((ends==2)|(ends==3)).*tan(tipangle/180*pi);
	le = [0 len0 wid/2 wid/2 slen0 0 -slen0 -wid/2 -wid/2 -len0 0];
	aprange = ap./limrange;
	aprange = [aprange aprange aprange aprange aprange aprange aprange aprange aprange aprange aprange];
	D = sqrt(sum(((Xf(1:2,:)-X0(1:2,:)).*aprange).^2));
	Dii=find(D==0); if ~isempty(Dii), D=D+(D==0); le(Dii)=zeros(1,length(Dii)); end; 
	tmp1 = X0.*(ones(4,1)*(1-le./D)) + Xf.*(ones(4,1)*(le./D));
%	inverse transform
	if (oneax), tmp3=invT*tmp1;
	else, tmp1=[tmp1;tmp1;tmp1;tmp1]; tmp1=[invT invT invT invT invT invT invT invT invT invT invT].*tmp1;
	      tmp2=zeros(4,44); tmp2(:)=tmp1(:);
	      tmp3=zeros(4,11); tmp3(:)=sum(tmp2)'; end;
	pts = tmp3(1:3,:)./(ones(3,1)*tmp3(4,:)) .* axr11 + axm11;
% correct for ones where the crossdir was specified
ii = find(~(all(crossdir==0)|any(isnan(crossdir))));
if ~isempty(ii),
	D1 = [pts(:,1+ii)-pts(:,9+ii) pts(:,2+ii)-pts(:,8+ii) ...
	      pts(:,3+ii)-pts(:,7+ii) pts(:,4+ii)-pts(:,6+ii) ...
	      pts(:,6+ii)-pts(:,4+ii) pts(:,7+ii)-pts(:,3+ii) ...
	      pts(:,8+ii)-pts(:,2+ii) pts(:,9+ii)-pts(:,1+ii)]/2;
	ii = ii'*ones(1,8) + ones(length(ii),1)*[1:4 6:9];   ii = ii(:)';
	pts(:,ii) = st(:,ii) + D1;
end;
% readjust for reverse directions
iicols = (1:1)';  iicols = iicols(:,ones(1,11));  iicols = iicols(:).';
tmp1 = axrev(:,iicols);
ii = find(tmp1(:)); if ~isempty(ii), pts(ii)=-pts(ii); end;
% readjust for log scale on axes
tmp1 = xyzlog(:,iicols);
ii = find(tmp1(:)); if ~isempty(ii), pts(ii)=10.^pts(ii); end;
% compute the x,y,z coordinates of the patches;
ii = (0:10)' + ones(11,1);
ii = ii(:)';
x = zeros(11,1);  y = x;    z = x;
x(:) = pts(1,ii)';   y(:) = pts(2,ii)';  z(:) = pts(3,ii)';
           % do the output
  % % create or modify the patches
H = 0; 
   % % make or modify the arrows
if arrow_is2DXY(ax(1)), zz=[]; else, zz=z(:,1); end;
xyz = {'XData',x(:,1),'YData',y(:,1),'ZData',zz,'Tag',ArrowTag};
H(1) = patch(xyz{:});
  % % additional properties
set(H,'Clipping','off');
set(H,{'UserData'},num2cell(ud,2));
  % make sure the axis limits did not change

function [out,is2D] = arrow_is2DXY(ax)
% check if axes are 2-D X-Y plots,  may not work for modified camera angles, etc.
	out = zeros(size(ax)); % 2-D X-Y plots
	is2D = out;            % any 2-D plots
	views = get(ax(:),{'View'});
	views = cat(1,views{:});
	out(:) = abs(views(:,2))==90;
	is2D(:) = out(:) | all(rem(views',90)==0)';

function out = arrow_WarpToFill(notstretched,manualcamera,curax)
% check if we are in "WarpToFill" mode.
	out = strcmp(get(curax,'WarpToFill'),'on');
	% 'WarpToFill' is undocumented, so may need to replace this by
	% out = ~( any(notstretched) & any(manualcamera) );

%%%%%%

function C = my_setdiff(A,B)
% MYSETDIFF Set difference of two sets of positive integers (much faster than built-in setdiff)
% C = my_setdiff(A,B)
% C = A \ B = { things in A that are not in B }

%  by Leon Peshkin pesha at ai.mit.edu 2004, inspired by BNT of Kevin Murphy
if isempty(A)
    C = [];
    return;
elseif isempty(B)
    C = A;
    return; 
else % both non-empty
    bits = zeros(1, max(max(A), max(B)));
    bits(A) = 1;
    bits(B) = 0;
    C = A(logical(bits(A)));
end
	
%%%%%%%%%%

% PROCESS_OPTIONS - Processes options passed to a Matlab function.
%                   This function provides a simple means of
%                   parsing attribute-value options.  Each option is
%                   named by a unique string and is given a default
%                   value.
%
% Usage:  [var1, var2, ..., varn[, unused]] = ...
%           process_options(args, ...
%                           str1, def1, str2, def2, ..., strn, defn)
%
% Arguments:   
%            args            - a cell array of input arguments, such
%                              as that provided by VARARGIN.  Its contents
%                              should alternate between strings and
%                              values.
%            str1, ..., strn - Strings that are associated with a 
%                              particular variable
%            def1, ..., defn - Default values returned if no option
%                              is supplied
%
% Returns:
%            var1, ..., varn - values to be assigned to variables
%            unused          - an optional cell array of those 
%                              string-value pairs that were unused;
%                              if this is not supplied, then a
%                              warning will be issued for each
%                              option in args that lacked a match.
%
% Examples:
%
% Suppose we wish to define a Matlab function 'func' that has
% required parameters x and y, and optional arguments 'u' and 'v'.
% With the definition
%
%   function y = func(x, y, varargin)
%
%     [u, v] = process_options(varargin, 'u', 0, 'v', 1);
%
% calling func(0, 1, 'v', 2) will assign 0 to x, 1 to y, 0 to u, and 2
% to v.  The parameter names are insensitive to case; calling 
% func(0, 1, 'V', 2) has the same effect.  The function call
% 
%   func(0, 1, 'u', 5, 'z', 2);
%
% will result in u having the value 5 and v having value 1, but
% will issue a warning that the 'z' option has not been used.  On
% the other hand, if func is defined as
%
%   function y = func(x, y, varargin)
%
%     [u, v, unused_args] = process_options(varargin, 'u', 0, 'v', 1);
%
% then the call func(0, 1, 'u', 5, 'z', 2) will yield no warning,
% and unused_args will have the value {'z', 2}.  This behaviour is
% useful for functions with options that invoke other functions
% with options; all options can be passed to the outer function and
% its unprocessed arguments can be passed to the inner function.

% Copyright (C) 2002 Mark A. Paskin
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
% USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [varargout] = process_options(args, varargin)

% Check the number of input arguments
n = length(varargin);
if (mod(n, 2))
  error('Each option must be a string/value pair.');
end

% Check the number of supplied output arguments
if (nargout < (n / 2))
  error('Insufficient number of output arguments given');
elseif (nargout == (n / 2))
  warn = 1;
  nout = n / 2;
else
  warn = 0;
  nout = n / 2 + 1;
end

% Set outputs to be defaults
varargout = cell(1, nout);
for i=2:2:n
  varargout{i/2} = varargin{i};
end

% Now process all arguments
nunused = 0;
for i=1:2:length(args)
  found = 0;
  for j=1:2:n
    if strcmpi(args{i}, varargin{j})
      varargout{(j + 1)/2} = args{i + 1};
      found = 1;
      break;
    end
  end
  if (~found)
    if (warn)
      warning(sprintf('Option ''%s'' not used.', args{i}));
      args{i}
    else
      nunused = nunused + 1;
      unused{2 * nunused - 1} = args{i};
      unused{2 * nunused} = args{i + 1};
    end
  end
end

% Assign the unused arguments
if (~warn)
  if (nunused)
    varargout{nout} = unused;
  else
    varargout{nout} = cell(0);
  end
end

%%%%%%%%%%%%

function M = removeRowsCols(M, rows, cols)
% Remove rows and columns from a matrix
% Example
% M = reshape(1:25,[5 5])
%> removeRowsCols(M, [2 3], 4)
%ans =
%     1     6    11    21
%     4     9    14    24
%     5    10    15    25
     
[nr nc] = size(M);

ndx = [];
for i=1:length(rows)
  tmp = repmat(rows(i), nc, 1);
  tmp2 = [tmp (1:nc)'];
  ndx = [ndx; tmp2];
end
for i=1:length(cols)
  tmp = repmat(cols(i), nr, 1);
  tmp2 = [(1:nr)' tmp];
  ndx = [ndx; tmp2];
end
if isempty(ndx), return; end
k = subv2ind([nr nc], ndx);
M(k) = [];
M = reshape(M, [nr-length(rows) nc-length(cols)]);

%%%%%%%%%

function M = setdiag(M, v)
% SETDIAG Set the diagonal of a matrix to a specified scalar/vector.
% M = set_diag(M, v)

n = length(M);
if length(v)==1
  v = repmat(v, 1, n);
end

% e.g., for 3x3 matrix,  elements are numbered
% 1 4 7 
% 2 5 8 
% 3 6 9
% so diagnoal = [1 5 9]


J = 1:n+1:n^2;
M(J) = v;

%M = triu(M,1) + tril(M,-1) + diag(v);


%%%%%%%%%%%

function ndx = subv2ind(siz, subv)
% SUBV2IND Like the built-in sub2ind, but the subscripts are given as row vectors.
% ind = subv2ind(siz,subv)
%
% siz can be a row or column vector of size d.
% subv should be a collection of N row vectors of size d.
% ind will be of size N * 1.
%
% Example:
% subv = [1 1 1;
%         2 1 1;
%         ...
%         2 2 2];
% subv2ind([2 2 2], subv) returns [1 2 ... 8]'
% i.e., the leftmost digit toggles fastest.
%
% See also IND2SUBV.

 
if isempty(subv)
  ndx = [];
  return;
end

if isempty(siz)
  ndx = 1;
  return;
end

[ncases ndims] = size(subv);

%if length(siz) ~= ndims
%  error('length of subscript vector and sizes must be equal');
%end

if all(siz==2)
  %rbits = subv(:,end:-1:1)-1; % read from right to left, convert to 0s/1s
  %ndx = bitv2dec(rbits)+1; 
  twos = pow2(0:ndims-1);
  ndx = ((subv-1) * twos(:)) + 1;
  %ndx = sum((subv-1) .* twos(ones(ncases,1), :), 2) + 1; % equivalent to matrix * vector
  %ndx = sum((subv-1) .* repmat(twos, ncases, 1), 2) + 1; % much slower than ones
  %ndx = ndx(:)';
else
  %siz = siz(:)';
  cp = [1 cumprod(siz(1:end-1))]';
  %ndx = ones(ncases, 1);
  %for i = 1:ndims
  %  ndx = ndx + (subv(:,i)-1)*cp(i);
  %end
  ndx = (subv-1)*cp + 1;
end

%%%%%%%%%%%

function d = bitv2dec(bits)
% BITV2DEC Convert a bit vector to a decimal integer
% d = butv2dec(bits)
%
% This is just like the built-in bin2dec, except the argument is a vector, not a string.
% If bits is an array, each row will be converted.

[m n] = size(bits);
twos = pow2(n-1:-1:0);
d = sum(bits .* twos(ones(m,1),:),2);

