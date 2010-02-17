function out=diffpen_normalgamma(w,shape,scale)
  lambda = shape;
gamma = sqrt(2*.scale);
out=gamma*besselk(lambda-3/2,gamma*abs(w),1)./besselk(lambda-1/2,gamma*abs(w),1);
out(isnan(out))=inf;
end