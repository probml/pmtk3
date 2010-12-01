function[X2,y2] = create_distorted_dataset(X,y,sig,alpha,n,m)
N = (n+1)*size(X,1);
X2 = zeros(N,size(X,2));
y2 = zeros(N,1);
index = 1;
for i=1:size(X,1)
    fprintf('distorting data point: %d\r',i);
    for j=1:n
        I = reshape(X(i,:),m,m);
        [Dx,Dy] = create_distortion_map(I,sig,alpha);
        I = distort_image(I,Dx,Dy);
        X2(index,:) = I(:)';
        y2(index) = y(i);
        index = index+1;
    end
    X2(index,:) = X(i,:);
    y2(index) = y(i);
    index = index+1;
end