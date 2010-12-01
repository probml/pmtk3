function i = imageAt(I,y,x)
[w,h] = size(I);
if (x <= 0 || y <= 0)
    i = 0;
    return;
end



if (x > w || y > h)
    i = 0;
    return;
end
i = I(y,x);