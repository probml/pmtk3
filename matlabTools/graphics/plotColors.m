
% This file is from matlabtools.googlecode.com

function [styles, colors, symbols, str] =  plotColors()

colors =  ['b' 'r' 'k' 'g' 'c' 'y' 'm' ...
	   'r' 'b' 'k' 'g' 'c' 'y' 'm'];
symbols = ['o' 'x' '*' '>' '<' '^' 'v' ...
	   '+' 'p' 'h' 's' 'd' 'o' 'x'];
styles = {'-', ':', '-.', '--', '-', ':', '-.', '--'};

for i=1:length(colors)
  str{i} = sprintf('-%s%s', colors(i), symbols(i));
end

end
