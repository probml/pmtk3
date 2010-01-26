function [colors, colorMap] = pmtkColors()
    
    lightblue = [55 155 255] / 255;
    orange    = [255 128 0   ] / 255;
    green     = [0   255 64  ] / 255;
    magenta   = [255 0   128 ] / 255;
    green2    = [132 199 71  ] / 255;
    cyan      = [61  220 176 ] / 255;
    yellow    = [215 215 0   ] / 255;
    
    
    brown     = [128 64  0   ] / 255;
    blue      = [0   0   255 ] / 255;
    
    colors = {lightblue, orange, green, magenta, yellow, cyan, yellow, brown, blue, green2};
    colors = repmat(colors, 1, 10);
    
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