% produce fig 5.1 from Rasmussen and Williams book
%PMTKauthor Carl Rasmussen

n = 61^2; D=2;
[x1,x2]=meshgrid(-3:0.1:3,-3:0.1:3);
x=[x1(:),x2(:)];


h = figure(1);
clf
set(gca,'FontSize',24);
randn('seed',37)
Q = zeros(n,n);
for d = 1:D
  Q = Q + (repmat(x(:,d),1,n)-repmat(x(:,d)',n,1)).^2;
end
Q = exp(-0.5*Q);
y = chol(Q+1e-9*eye(n))'*randn(n,1);
mesh(x1,x2,reshape(y,sqrt(n),sqrt(n)));
xlabel('input x1')
ylabel('input x2')
zlabel('output y')
axis square
axis([-3 3 -3 3 -2 2])
set(h,'PaperPosition', [0.25 2.5 8 8])
grid off
%print -depsc ard1.eps


h = figure(2);
clf
set(gca,'FontSize',24);
randn('seed',34)
Q = zeros(n,n);
Q = Q + (repmat(x(:,1),1,n)-repmat(x(:,1)',n,1)).^2;
Q = Q + (repmat(x(:,2),1,n)-repmat(x(:,2)',n,1)).^2/9;
Q = exp(-0.5*Q);
y = chol(Q+1e-9*eye(n))'*randn(n,1);
mesh(x1,x2,reshape(y,sqrt(n),sqrt(n)));
xlabel('input x1')
ylabel('input x2')
zlabel('output y')
axis square
axis([-3 3 -3 3 -2 2])
set(h,'PaperPosition', [0.25 2.5 8 8])
grid off
%print -depsc ard2.eps


h = figure(3);
clf
set(gca,'FontSize',24);
randn('seed',34)
L = [1 -1];
xL = x*L';
Q = zeros(n,n);
Q = Q + (repmat(xL(:,1),1,n)-repmat(xL(:,1)',n,1)).^2;
Q = Q + (repmat(x(:,1),1,n)-repmat(x(:,1)',n,1)).^2/36;
Q = Q + (repmat(x(:,2),1,n)-repmat(x(:,2)',n,1)).^2/36;
Q = exp(-0.5*Q);
randn('seed',34)
y = chol(Q+1e-9*eye(n))'*randn(n,1);
mesh(x1,x2,reshape(y,sqrt(n),sqrt(n)))
xlabel('input x1')
ylabel('input x2')
zlabel('output y')
axis square
axis([-3 3 -3 3 -2 2])
set(h,'PaperPosition', [0.25 2.5 8 8])
grid off
%print -depsc ard3.eps

