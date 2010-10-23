function h=pdffigure(varargin)
% Just like figure, except makes the paper size equal to the figure size

% This file is from matlabtools.googlecode.com


h=figure(varargin{:});
pdfcrop(h);

end
