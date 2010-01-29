function C = evalNtimes(code,n)
    
    C = cell(n,1);
    for i=1:n
       C{i} = eval(code); 
    end
   
end