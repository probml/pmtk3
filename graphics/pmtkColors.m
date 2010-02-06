function [colors, colorMap] = pmtkColors()
    
% http://www.mathworks.com/access/helpdesk/help/techdoc/ref/colorspec.html

    lightblue = [55 155 255] / 255;
    orange    = [255 128 0   ] / 255;
    green     = [0   255 64  ] / 255;
    magenta   = [255 0   128 ] / 255;
    green2    = [132 199 71  ] / 255;
    cyan      = [61  220 176 ] / 255;
    yellow2    = [215 215 0   ] / 255;
    yellow    = [255 25 0   ] / 255;
    brown     = [128 64  0   ] / 255;
    blue      = [0   0   255 ] / 255;
    red      = [255   0   0 ] / 255;
    black      = [0   0   0 ] / 255;
    gray      = [128   128   128 ] / 255;
     
    colors = { lightblue, orange, green, magenta, yellow, cyan, ...
      brown, blue, green2, red, gray, black};
    colors = repmat(colors, 1, length(colors));
    
    colorMap.lightblue = lightblue;
    colorMap.orange    = orange;
    colorMap.green     = green;
    colorMap.cyan      = cyan;
    colorMap.yellow    = yellow;
    colorMap.magenta   = magenta;
    colorMap.green2    = green2;
    colorMap.brown     = brown;
    colorMap.blue      = blue;
end