
function sigmoidBounds()

x = [-6:(1/10):6];

function sigupper = sigupper(eta,x)
  sigupper = exp(eta * x - fstar(eta));
end

function fstar = fstar(eta)
  fstar = -eta * log(eta) - (1-eta) * log(1-eta);
end

function sig = sigmoid(x)
  sig = exp(x) ./ (1 + exp(x));
end

function siglower = siglower(xi,x)
  siglower = sigmoid(xi) * exp((x-xi)/2 - lambda(xi)*(x.^2 - xi^2));
end

function lambda = lambda(xi)
  lambda = 1/(2*xi) * (sigmoid(xi) - 1/2);
end


eta1 = 0.2;
eta2 = 0.7;
xi = 2.5;

% Figure (a)
axis([-6 6 0 1]);
hold on;
plot(x,sigmoid(x),'r','linewidth',3);
plot(x,sigupper(eta1,x),'b','linewidth',3);
plot(x,sigupper(eta2,x),'b','linewidth',3);

% text('Interpreter','latex','String',$$\eta = 0.2$$, 'Position', [1/2,sigupper(eta1,1/2)]);
% text('Interpreter','latex','String',$$\eta = 0.7$$, 'Position', [0,sigupper(eta2,0)]);
text(1/2 + 1/2,sigupper(eta1,1/2),'eta = 0.2');
text(0 + 1/2,sigupper(eta2,0),'eta = 0.7');
hold off;


figure;
axis([-6 6 0 1]);
hold on;
plot(x,sigmoid(x), 'r','linewidth',3);
plot(x,siglower(xi,x),'b','linewidth',3);
line([-xi,-xi],[0,sigmoid(-xi)],'color','green','linewidth',3);
line([xi,xi],[0,sigmoid(xi)],'color','green','linewidth',3);
text(2.75,1/4,'xi = 2.5');
hold off;


end

