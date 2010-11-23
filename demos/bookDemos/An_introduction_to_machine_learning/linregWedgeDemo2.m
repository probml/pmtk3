%% Plot Linear Gaussian CPD p(y|x) = N(Y|a + bx, sigma) 
% Here a is the offset and b is the slope. 
%%

% This file is from pmtk3.googlecode.com

[xtrain, ytrain, xtest, ytestNoisefree, ytest] = polyDataMake('sampling','thibaux');
n = size(xtrain,1);
Xtrain = [ones(n,1) xtrain];
w = Xtrain\ytrain;

ntest = size(xtest,1);
Xtest = [ones(ntest,1) xtest];
ypredTest = Xtest*w;

figure;
scatter(xtrain,ytrain,'b','filled');
hold on;
plot(xtest, ypredTest, 'k', 'linewidth', 3);
hold off
%set(gca,'ylim',[-10 15]);
set(gca,'xlim',[-1 21]);
%%
sigma = 1;
a = w(1);
b = w(2); 
stepSize = 0.1; 
%[x,y] = meshgrid(0:stepSize:10,0:stepSize:10);
[x,y] = meshgrid(linspace(min(xtest), max(xtest), 300), ...
  linspace(min(ypredTest),max(ypredTest),300));
[r,c]=size(x);

func = @(X,Y)uniGaussPdf(Y,a + b*X,sigma.^2);

p = func(x(:),y(:));
p = reshape(p, r, c);

fontSize = {'FontSize',14};

figure;
mesh(x,y,p);
shading interp;
lighting phong;
material dull;
%view([-47.5 34]);
xlabel('X',fontSize{:});
ylabel('Y',fontSize{:});
zlabel('P(Y | X)',fontSize{:});
%set(gca,'XTick',[0,5,10],'YTick',[0,5,10],'ZTick',0:0.1:0.5);
set(gca,fontSize{:},'LineWidth',1.5);
printPmtkFigure('linregWedge2Wedge'); 
