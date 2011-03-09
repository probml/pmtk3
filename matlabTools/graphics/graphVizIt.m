function [] = graphVizIt(adj,labels,landscape,removeDisconnected)
% graphVizIt(adj,labels)
%
% Path to graphViz is hard-coded in this function

nNodes = length(adj);
if nargin < 2
    for n = 1:nNodes
        labels{n} = sprintf('%d',n);
    end
end

if nargin < 3
    landscape = 1;
end

if nargin < 4 || removeDisconnected
    n = 1;
    while n <= length(adj);
        if sum(adj(:,n))+sum(adj(n,:)) == 0
           adj = adj([1:n-1 n+1:end],[1:n-1 n+1:end]);
           labels = labels([1:n-1 n+1:end]);
        else
            n = n+1;
        end
    end
    nNodes = length(adj);
end

makeUndirected = 1;

fid = fopen('graphVizIt.txt','w+');

fprintf(fid,'digraph G {\ncenter = 1;\nsize=\"10,10\";\n');

for n = 1:nNodes
    fprintf(fid,'%d [ label = \"%s\" ];\n',n,labels{n});
end

for n1 = 1:nNodes
    for n2 = 1:nNodes
        if adj(n1,n2) == 1
            if makeUndirected && adj(n2,n1) == 1
                if n1 < n2
                    % Undirected edge
                    fprintf(fid,'%d -> %d [dir = \"none\" ];\n',n1,n2);
                end
            else
                % Directed edge
                fprintf(fid,'%d -> %d;\n',n1,n2);
            end
        end
    end
end

fprintf(fid,'}\n');

fclose(fid);

% Useful options:
%   -Glandscape (outputs in landscape mode)
%   -Gconcentrate (merges two-way edges into one way edge, displays
%   parallel edges in different way)
%   -Gratio=.707 (changes to A4 landscape aspect ratio, other options are "fill", "compress",
%   "expand", "auto")
%   -Ncolor="blue" (changes node outlines to blue)
%   -Ecolor="red" (changes edges to red)
%   -Earrowsize=2 (changes size of arrows)
%   -Nstyle="filled" -Nfillcolor="#ddddff" (make nodes light blue)
%   -Nfontsize=32 (change font size to 32pt)
%   -Gnodesep=0.125 (make nodes twice as close
%   -Nshape="box" (change node shape to box)
%
% Details here:
% http://www.graphviz.org/doc/info/attrs.html
if landscape
    opts = ' -Gconcentrate -Gratio=.707 -Ncolor="blue" -Ecolor="green" -Earrowsize=2 -Nstyle="filled" -Nfillcolor="#ddddff" -Nfontsize=40 ';
    opts = strcat(opts,' -Glandscape ');
else
    opts = ' -Gconcentrate -Ncolor="blue" -Ecolor="green" -Earrowsize=2 -Nstyle="filled" -Nfillcolor="#ddddff" -Nfontsize=40 ';
end

if 0
    cmd = strcat('"D:\Program Files\Graphviz2.26.3\bin\dot" ',opts,' -T ps -o graphVizIt.ps graphVizIt.txt ')
else
   cmd = strcat('C:\temp\graphviz-2.8\bin\dot ',opts,' -T ps -o graphVizIt.ps graphVizIt.txt ')
end
system(cmd);
system('graphVizIt.ps');