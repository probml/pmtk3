%% Visualize the geometry of ridge regression

w1 = [-2:(1/10):6]';
w2 = w1;

xbar = [3;3];
S = [3,0;0,1];

Mu0 = [0;0];
Sigma0 = eye(2);

n1 = length(w1);
n2 = length(w2);

likelihood = zeros(n2,n1);
prior = zeros(n2,n1);

for i=1:n1
  likelihood(:,i) = mvnpdf([repmat(w1(i),n2,1),w2], xbar, S);
  prior(:,i) = mvnpdf([repmat(w1(i),n2,1),w2], Mu0, Sigma0);
end

hold on;
axis([-2 6 -2 6], 'nolabel');
contour(w1, w2, likelihood, 1, 'linecolor', 'red','linewidth',3);
contour(w1, w2, prior, 1, 'linecolor', 'green','linewidth',3);

wml = xbar;

m0 = 2; n = 1;

wmap = (n*S + m0*Sigma0)\(n*S) * xbar; 

plot(wmap(1), wmap(2), 'b*','linewidth',3);
% text('Interpreter', 'latex', 'String', '$$w_{MAP}$$', 'Position', [wmap(1) + 1/2, wmap(2)]);

text(wmap(1) + 1/4, wmap(2), 'MAP Estimate', 'color', 'blue');
plot(wml(1), wml(2), 'r*','linewidth',3);
text(wml(1) + 1/4, wml(2) + 1/4, 'ML Estimate', 'color', 'red');

line([wml(1),wml(1)+2],[wml(2),wml(2)],'linewidth',3)
text(wml(1)+2,wml(2)+1/2,'u_1');

line([wml(1),wml(1)],[wml(2),wml(2)+2],'linewidth',3)
text(wml(1)+1/2,wml(2)+2,'u_2');



