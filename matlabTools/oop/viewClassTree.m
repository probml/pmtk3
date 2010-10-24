function  h = viewClassTree(varargin)
% View a class inheritence hierarchy. 
% Same args as getClasses 
% Needs graphViz4Matlab
% Classes must use classdef syntax not old style
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com


args = process_options(varargin,'source',pwd(),'ignoreDirs',{'unitTests',fullfile('util','graphs','graphlayout')},'topOnly',false,'topClass',[]);
[topClass,unusedArgs] = extractArgs(4,args);
layout = Treelayout();

[classes,matrix] = classesBFS(unusedArgs{:});
classMap = enumerate(classes);

if ~isempty(topClass)
    keep = [classMap.(topClass),descendants(matrix,classMap.(topClass))];
    classes = classes(keep);
    matrix = matrix(keep,keep);
    classMap = enumerate(classes);
end


nodeColors = repmat([0.9,0.9,0.5],numel(classes),1);
shortClassNames = shortenClassNames(classes);
%nodeDescriptions = cell(numel(classes,1));
for c=1:numel(classes)
   if isabstract(classes{c}),  nodeColors(c,:) = [0.8,0.3,0.2];  end
   %nodeDescriptions{c} = catString(localMethods(classes{c},true),', ');
end

%%
% Color these nodes and their outgoing edges. First come first serve - if a
% node has two incomming edges of different colors, the color of its
% outgoing edges will be whichever comes first in this list. 

specialColors = {'BayesModel'         ,[72  , 217 , 217 ] ./255;
                 'CondModel'          ,[0   , 255 , 0   ] ./255;
                 'LatentVarModel'     ,[128 , 0   , 255 ] ./255;
                 'GraphicalModel'     ,[239 , 167 , 16  ] ./255;
                 'NonFiniteParamModel',[ 0  , 0   , 255 ] ./255;
                 'ProbDist'           ,[0   , 128 , 64  ] ./255;
                 'ModelEnsemble'      ,[221,  0   , 0   ] ./255;
                };

edgeColors = {};
for i=1:size(specialColors,1)
    nodeName = specialColors{i,1};
    if any(findString(nodeName,classes))
        color = specialColors{i,2};
        edgeColors = [edgeColors;{nodeName,'all',color}]; %#ok
        C = descendants(matrix,classMap.(nodeName));
        for k=1:numel(C)
           if ~isleaf(matrix,C(k));
              edgeColors = [edgeColors;{classes{C(k)},'all',color}];  %#ok
           end
        end
        nodeColors(classMap.(nodeName),:) = color;
    end
end
NYItag = '%PMTKnotYetImplemented';
ndx = cellfun(@(c)hasTag(which(c),NYItag),classes);
nodeColors(ndx,:) = repmat([180,180,180]./255,sum(ndx),1); % grey

%%
if ~isempty(edgeColors)
    [E,ndx] = unique(edgeColors(:,1),'first');
    edgeColors = edgeColors(ndx,:);
end

    function dblcfun(label)
       h = viewClassTree('topClass',label); 
       for i=1:2,shrinkNodes(h);end
       increaseFontSize(h);
    end

doubleClickFn = @dblcfun;


%% Visualize
h = drawNetwork('-adjMat',matrix,'-nodeLabels',shortClassNames,'-splitLabels',true,'-layout',layout,'-nodeColors',nodeColors,'-edgeColors',edgeColors,'-doubleClickFn',doubleClickFn);
maximizeFigure();
pause(1);
tightenAxes(h);
for i=1:1, growNodes(h); end
for i=1:4, increaseFontSize(h); end
%%






function classNames = shortenClassNames(classNames)
    remove = {};            % add to this list to remove other partial strings - case sensitive
    for r=1:numel(remove)
        ndx = strfind(classNames,remove{r});
        for j=1:numel(classNames)
           if(~isempty(ndx{j}))
               classNames{j}(ndx{j}:ndx{j}+length(remove{r})-1) = [];
           end
        end
    end
    
end

end
