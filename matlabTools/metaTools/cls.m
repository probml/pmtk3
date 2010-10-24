%% Clear and close everything

% This file is from pmtk3.googlecode.com

close all;
close all hidden;
fclose all;
clear all
clear classes;
clear global;
clear java;
dbclear if warning;
try
    dbquit('all');
catch
end
clc;
