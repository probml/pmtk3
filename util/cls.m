close all;
close all hidden;
fclose all;
clear classes;
clear global;
clear java;
dbclear if error;
dbclear if warning;
try
    dbquit('all');
catch
end
clc;
