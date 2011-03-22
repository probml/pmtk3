function [colors, colorMap] = pmtkColors()
    
% http://www.mathworks.com/access/helpdesk/help/techdoc/ref/colorspec.html

% This file is from pmtk3.googlecode.com


    lightblue = [55 155 255] / 255;
    orange    = [255 128 0   ] / 255;
    green     = [0   255 64  ] / 255;
    magenta   = [255 0   128 ] / 255;
    olivegreen    = [132 199 71  ] / 255;
    %cyan      = [61  220 176 ] / 255;
    yellow2    = [215 215 0   ] / 255;
    red1    = [255 25 0   ] / 255;
    brown     = [128 64  0   ] / 255;
    blue      = [0   0   255 ] / 255;
    red      = [255   0   0 ] / 255;
    black      = [0   0   0 ] / 255;
    gray      = [128   128   128 ] / 255;
     
    colors = { lightblue, orange, green,  red1,  ...
      brown, blue,  black};
    %colors = repmat(colors, 1, 5);
    
    colorMap.lightblue = lightblue;
    colorMap.orange    = orange;
    colorMap.green     = green;
    %colorMap.cyan      = cyan;
    colorMap.yellow    = yellow2;
    colorMap.magenta   = magenta;
    colorMap.olivegreen    = olivegreen;
    colorMap.brown     = brown;
    colorMap.blue      = blue;
end
