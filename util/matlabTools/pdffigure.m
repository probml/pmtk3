function h=pdffigure(varargin);
% Just like figure, except makes the paper size equal to the figure size

h=figure(varargin{:});
pdfcrop(h);