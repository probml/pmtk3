function C = insertFront(element, C)
if size(C, 1) >= size(C, 2)
    C = [element; C];
else
    C = [element, C];
end

end