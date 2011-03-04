classdef Matrixlayout < Abstractlayout
%% Create a specialized layout to display a grid in matlab matrix order
% i.e. [1 4 7
%       2 5 8
%       3 6 9];
%%

% This file is from pmtk3.googlecode.com

    properties
        xmin;               % The left most point on the graph axis in data units
        xmax;               % The right most point on the graph axis in data units
        ymin;               % The bottom most point on the graph axis in data units
        ymax;               % The top most point on the graph axis in data units
        adjMatrix;          % The adjacency matrix
        maxNodeSize;        % The maximum diameter of a node in data units
        image;              % An image for the button that will lanuch this layout
        name;               % A unique name for instances of this class
        shortDescription;   % A description for use in the tooltips
        nodeSize;           % The calculated node size, call dolayout() before accessing
        centers;            % The calculated node centers in an n-by-2 matrix
        M;                  % number of rows
        N;                  % number of columns
    end
    
    methods
        function obj = Matrixlayout(N, M)
            % constructor
            obj.name = 'Matrixlayout';
            load glicons;
            obj.image = icons.grid;
            obj.shortDescription = 'Matrix Layout';
            obj.N = N;
            obj.M = M;
        end
        
    end
    methods(Access = 'protected')
        function calcLayout(obj)
            N = obj.N;
            M = obj.M;
            xspacePerNode = (obj.xmax - obj.xmin)/M;
            yspacePerNode = (obj.ymax - obj.ymin)/N;
            obj.nodeSize  =  min(min([xspacePerNode, yspacePerNode]./2), obj.maxNodeSize);
            xstart  = obj.xmin + (xspacePerNode)/2;
            ystart  = obj.ymin + (yspacePerNode)/2;
            nnodes  = size(obj.adjMatrix, 1);
            centers = zeros(nnodes, 2);
            counter = 1;
            for i = 1:M
                for j = N:-1:1
                    centers(counter, 1) = xstart + (i-1)*xspacePerNode;
                    centers(counter, 2) = ystart + (j-1)*yspacePerNode;
                    counter = counter + 1;
                end
            end
            obj.centers = centers;
        end
    end
end
