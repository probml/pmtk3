function [styles, colors, symbols, str] =  plotColors()
% Use plot(x,y,str{i}) to print in i'th style 
% We use colors and linestyles, not markers

% This file is from pmtk3.googlecode.com

colors =  ['b' 'r' 'k' 'g' 'c' 'y' 'm' ...
	   'r' 'b' 'k' 'g' 'c' 'y' 'm'];
symbols = ['o' 'x' '*' '>' '<' '^' 'v' ...
	   '+' 'p' 'h' 's' 'd' 'o' 'x'];
styles = {'-', ':', '-.', '--', '-', ':', '-.', '--', ...
  '-', ':', '-.', '--', '-', ':', '-.', '--'};

for i=1:length(colors)
  %str{i} = sprintf('-%s%s', colors(i), symbols(i));
  str{i} = sprintf('%s%s', colors(i), styles{i});
end

end
