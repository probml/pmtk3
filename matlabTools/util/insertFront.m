function C = insertFront(element, C)
% Add an element to the front of a cell array

% This file is from pmtk3.googlecode.com

if size(C, 1) >= size(C, 2)
    C = [element; C];
else
    C = [element, C];
end
end
