function df = numericalGradient(f, x, args)
% We assume f is a function of the form v=f(X,args) 
% where v(i)=f(X(:,i), args) computed in parallel
% args is a cell array; use {} if no args required

% This file is from pmtk3.googlecode.com


n = length(x);
df = zeros(n,1);
method = 'complex';
%method =  'centralDifference';
switch method
 case 'complex'
  h = 1e-20;
  for k=1:n
    e = zeros(n,1); e(k) = 1;
    df(k) = imag(feval(f, x + h*e*1i, args{:}))/h; 
  end
 case 'firstorder',
  h = 0.0001; 
  fx = feval(f, x(:), args{:});
  for k=1:n
    e = zeros(n,1); e(k) = 1;
    df(k) = (feval(f, x + h*e, args{:}) - fx)/h;
  end
  case 'centralDifference'
  h=.0001; 
  for k=1:n
    e = zeros(n,1); e(k) = 1;
    t = feval(f, [x-h/2*e  x+h/2*e], args{:}); % eval fn at 2 pints
    df(k) = (t(2)-t(1))/h;
  end
end

end
