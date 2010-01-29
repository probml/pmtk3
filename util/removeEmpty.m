function c = removeEmpty(c)
    
   c = c(cellfun(@(a)~isempty(a),c)); 
end