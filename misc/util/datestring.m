function d = datestring()
    
   d = datestr(now); d(d ==':') = '_'; d(d == ' ') = '_'; d(d=='-') = []; 
    
end