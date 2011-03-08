function graphviz(adj, varargin)
% Calls graphviz to generate a pretty layout of an adjacency matrix
% You must first install graphviz from http://www.graphviz.org/
% This function converts the adjmat to a .dot file,
% and then calls graphviz to generate a .ps file.
% Finally we convert this to a .pdf file.
% Unlike graphviz4matlab (from http://code.google.com/p/graphviz4matlab/)
% we do not display the figure in Matlab.
% This simplifies the code a lot!
%
% graphviz(adjMat, ...)  where ... are optional arguments
% in  (string/value pair) [default in brackets]
%
% labels - labels{i} is a *string* for node i [1:n]
% removeSelfLoops - [1]
% removeIsolatedNodes - [1]
% filename - name for output file [default foo.pdf]
% directed - [default: determine from symmetry of adj] 
%
%
%
% Examples
% graphviz(adj, 'filename', 'foo') % default tmp
% graphviz(adj, 'labels', {'a','bbbb','c','d','e'})
% graphviz(adj, 'removeIsolatedNodes', 0, 'removeSelfLoops', 0);
%
% Written by Kevin Murphy, Leon Peshkin, et al 
% 8 March 2011



% This file is from pmtk3.googlecode.com
 
%{
Examples:
adj = zeros(5,5);
adj(1,2)=1; adj(4,5)=1; adj(5,4)=1; adj(1,1) = 1;
graphviz(adj, 'filename', 'foo.pdf')
graphviz(adj)
graphviz(adj, 'labels', {'a','bbbb','c','d','e'})
graphviz(adj, 'removeIsolatedNodes', 1, 'removeSelfLoops', 0);
%}

%

[labels, removeSelfLoops, removeIsolatedNodes, filename, directed] = ...
    process_options(varargin,  ...
		    'labels', [], 'removeSelfLoops', 1, ...
		    'removeIsolatedNodes', 0, 'filename','tmp', 'directed', []);

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

tmpDOTfile = sprintf('%s.dot', filename);

graph_to_dot(adj, 'directed', directed, ...
  'filename', tmpDOTfile, 'node_label', labels);

cmd = sprintf('dot  -Tps %s -o %s.ps', tmpDOTfile, filename);
status = system(cmd);

if ~isempty(filename)
  cmd = sprintf('ps2pdf %s.ps %s.pdf', filename, filename);
  status = system(cmd);
  if status ~= 0
    error(sprintf('error executing %s', cmd));
  end
  
  
  cmd = sprintf('rm %s.ps', filename);
  status = system(cmd);
  if status ~= 0
    error(sprintf('error executing %s', cmd));
  end
  
  cmd = sprintf('rm %s.dot', filename);
  status = system(cmd);
  if status ~= 0
    error(sprintf('error executing %s', cmd));
  end
end

end


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
end

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
end