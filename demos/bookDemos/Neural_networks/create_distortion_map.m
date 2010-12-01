function[Dx,Dy] = create_distortion_map(I,sig,alpha,gausswidth)
[w,h] = size(I);
Dx = zeros(w,h);
Dy = zeros(w,h);
for i=1:w
    for j=1:h
        Dx(i,j) = 2*rand()-1;
        Dy(i,j) = 2*rand()-1;
    end
end
h = fspecial('gaussian',gausswidth,sig);

Dx = conv2(Dx,h,'same');
Dy = conv2(Dy,h,'same');

Dx = alpha*(Dx./norm(Dx));
Dy = alpha*(Dy./norm(Dy));
