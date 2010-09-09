function H = numericalHessian(f, x, args)
n = length(x);
H = zeros(n,n);
method = 'centralDifference';
%method = 'gradient';

% This file is from pmtk3.googlecode.com

switch method
  case 'gradient'
   h = 0.001;
   gx = numericalGradient(f, x, args{:});
   for k=1:n
     e = zeros(n,1); e(k) = 1;
     H(:,k) = (numericalGradient(f, x+h*e, args{:}) - gx)/h;
   end
   H = (H+H')/2;
 case 'centralDifference';
  h=0.001;
  s=[-h;0;h]';
  x2=[x(:) x(:) x(:)];
  for k=1:n
    y=x2; y(k,:)=y(k,:)+s;
    t=feval(f, y, args{:});
    H(k,k)=(t(1)-2*t(2)+t(3))/h^2;
  end
  s=[h/2 h/2; -h/2 h/2; h/2 -h/2; -h/2 -h/2]';
  x2=repmat(x(:), 1, 4); % eval fn at 4 points
  for k=1:n
    for j=(k+1):n
      y=x2; y([k j],:)=y([k j],:)+s;
      t=feval(f,y,args{:});
      v=(t(1)-t(2)-t(3)+t(4))/h^2;
      H(k,j)=v; H(j,k)=v;
    end
  end
end

end
