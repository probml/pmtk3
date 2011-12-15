function dtdisplay(tree)
%A very simple visualizatiion of the tree, which shows the feature that was
%used to split each node. 
    
    figure('color',[1,1,1]);
    axis off;
    hold on;
    width = 10;
    height = 10;
    markerSize = 10;
    markerType = 's';
    
    plot(0,0,markerType,'MarkerSize',markerSize);
    plotChildren(tree,0,0);
    
    
    function plotChildren(node,x,y)
        
        text(x,y+1.5,num2str(node.splitFeature));
        plot(x,y,markerType,'MarkerSize',markerSize);
        newY = y - height;
        
        if(~isempty(node.left))
            newX = x - width - 2^(length(node.features));
            plot([x;newX],[y;newY],'-');
            plotChildren(node.left,newX,newY);
        end
        
        if(~isempty(node.right))
            newX = x + width + 2^(length(node.features));
            plot([x;newX],[y;newY],'-');
            plotChildren(node.right,newX,newY);
        end
    end



    

end