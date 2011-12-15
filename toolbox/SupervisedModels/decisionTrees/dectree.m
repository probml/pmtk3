classdef dectree < handle
%Decision tree data structure. 
    
    properties
       isRegression;    %0 for classification, 1 for regression.
       examples;        %Indicies of the training examples directed to this node during fitting. 
       features;        %Indicies of all available features remaining at this node including the splitting node. 
       splitFeature;    %Index of the feature that will split this node, if any.
       fork;            %Handle to a function that takes in a new example and returns either 0 for 'right' or 1 for 'left' 
       yhat;            %Predicted output for any example that reaches and remains at this node.  
       left =  [];      %Left  child
       right = [];      %Right child
    end
    
    methods
        
        function display(node)
        %Overloaded to display object in previous matlab versions. 
           meta = eval(['?',class(node)]);
           properties = struct;
           for p = 1: numel(meta.Properties)
                pname = meta.Properties{p}.Name;
                properties.(pname) = node.(pname);
           end
           display(properties);
        end
        
    end
    
end