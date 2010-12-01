function[I2] = distort_image(I,Dx,Dy)
[h,w] = size(I);
I2 = zeros(w,h);
for x=1:w
    for y=1:h
        dx = Dx(y,x);
        dy = Dy(y,x);
        i1 = imageAt(I,y+floor(dy),x+floor(dx)) + (dx-floor(dx))*(imageAt(I,y+floor(dy),x+ceil(dx))-imageAt(I,y+floor(dy),x+floor(dx)));
        i2 = imageAt(I,y+ceil(dy),x+floor(dx)) + (dx-floor(dx))*(imageAt(I,y+ceil(dy),x+ceil(dx))-imageAt(I,y+ceil(dy),x+floor(dx)));
        I2(y,x) = i1 + (dy-floor(dy))*(i2-i1);
    end
end