function D = wrapData(d)
   
    if iscell(d)
        D = DataSequence(d);
    else
        D = DataTable(d);
    end
    
    
end