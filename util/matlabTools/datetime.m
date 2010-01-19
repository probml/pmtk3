function d = datetime()
% Return a formatted string of the date and time, without spaces or ':'
% characters.

    dt = tokenize(datestr(now));
    d = [dt{1},'_',dt{2}(dt{2}~=' ' & dt{2} ~=':')];
    d(d=='-') = '_';
    
    

end