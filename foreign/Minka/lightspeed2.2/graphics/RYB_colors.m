function colors = RYB_colors(n)
% RYB_colors    A good diverging colormap.
% RYB_colors(n) returns an RGB matrix of n colors (default 7).
% These colors form a diverging colormap (colors easily perceived to lie
% on a sequence on either side of a central color).
%
% Example:
%   colormap(RYB_colors)
%
% See also YR_colors.

% Written by Tom Minka

if nargin < 1
  n = 7;
end

% In R: col2rgb(RYB.colors(3))
switch n
  case 7,
    colors = [ 
      215    61   41;
      252   141   89;
      254   224  144;
      255   255  191;
      224   243  248;
      145   191  219;
      69   117  180
      ]/255;
  case 6,
    colors = [
       215    61   41
       252   141   89
       254   224  144
       224   243  248
       145   191  219
        69   117  180
      ]/255;
  case 5,
    colors = [
       202    55   59
       253   174   97
       255   255  191
       171   217  233
        44   123  182
	]/255;
  case 4,
    colors = [ 
      202    55   59;
      253   174   97
      171   217  233;
       44   123  182
       ]/255;
   case 3,
     colors = [ 
       252   141   89; 
       255   255  191; 
       145   191  219
       ]/255;
end
