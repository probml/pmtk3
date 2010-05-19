function C = insertFront(element, C)
% Add an element to the front of a cell array
if size(C, 1) >= size(C, 2)
    C = [element; C];
else
    C = [element, C];
end
end