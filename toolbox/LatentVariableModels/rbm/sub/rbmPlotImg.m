function r=rbmPlotImg(X, doTranspose)
% X(:,i) is i'th data case or weight vector.
% If possible, reshape it as an image and make
% a composite image of all of them.
% If no return argument is request, plot image,
% otherwise return it.

% This file is from pmtk3.googlecode.com


if nargin < 2, doTranspose = false; end
[D,N]= size(X);
s=sqrt(D);
if s==floor(s)
  %its a square, so data is probably an image
  num=ceil(sqrt(N));
  a=zeros(num*s+num+1,num*s+num+1)-1;
  x=0;
  y=0;
  for i=1:N
    if doTranspose
      a(x*s+1+x:x*s+s+x,y*s+1+y:y*s+s+y)=reshape(X(:,i),s,s)';
    else
      a(x*s+1+x:x*s+s+x,y*s+1+y:y*s+s+y)=reshape(X(:,i),s,s);
    end
    
    
    x=x+1;
    if(x>=num)
      x=0;
      y=y+1;
    end
  end
  d=true;
else
  %there is not much we can do
  a=X;
end

%return the image, or plot the image
if nargout==1
  r=a;
else
  imshow(a,[-1,1]);
end
end
