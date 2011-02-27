function bayesRiskDemo()

% draw_bayesrisk.m
% Illustrates the symmetry of Bayesian and Frequentist Decision Theory.
%
%PMTKauthor Gabriel Goh.
% 10 Jan 2010

range = 10;
res = 0.1;

[theta, x_bar] = meshgrid(-range:res:range,-range:res:range);

% Number of observations. Note that as n increases, both the Bayesian and
% Frequentist estimates become sharper and converge to each other.
n = 1

% Where to place the camera
V =[[-0.6561    0.7547         0   -0.0493];
    [-0.4436   -0.3856    0.8090    0.0101];
    [-0.6106   -0.5308   -0.5878    9.5248];
    [     0         0         0    1.0000]];

% If you get weird errors about the view function, uncomment the line
% below.
V = 3
normpdf = @(val,mean,sd) (1/(2*pi*sd^2))*exp(-(val-mean).^2/(2*sd));
%% Frequentist Diagrams

figure;

subplot(2,2,1)

% L(theta,delta(x))*P(x_bar|theta)
fn =  @(theta_ij,x_bar_ij)((theta_ij - (1)*x_bar_ij)^2)*normpdf(x_bar_ij,theta_ij,1/n);

lines3d(theta,x_bar,fn,...
        'xcol', @(X)[exp(-(X.^2)/10), 0, 0],...
        'ydraw', 0,...
        'border',50,...
        'axis',[-5  5 -5  5]);
view(V);
%view(V(:,1:3))

subplot(2,2,2)

% P(x_bar|theta)
fn =  @(theta_ij,x_bar_ij)normpdf(x_bar_ij,theta_ij,1/n);

lines3d(theta, x_bar, fn,...
        'xcol', @(X)[exp(-(X.^2)/10), 0, 0],...
        'ydraw', 0,...
        'xfunction',@(X)exp(-X.^2)/5, ...
        'xsum', 1,...
        'border',50,...
        'axis',[-5  5 -5  5]);
view(V);

subplot(2,2,3)

% L(theta,delta(x))*P(x_bar|theta)*P(theta)
fn =  @(theta_ij,x_bar_ij)((theta_ij - (1)*x_bar_ij)^2)*normpdf(x_bar_ij,theta_ij,1/n)*normpdf(theta_ij,0,1);

lines3d(theta, x_bar, fn,...
        'ydraw', 0,...
        'xsum',1,...
        'border',50,...
        'axis',[-5  5 -5  5]);
view(V);
    
subplot(2,2,4)

% L(theta,delta(x))
fn =  @(theta_ij,x_bar_ij)((theta_ij - (1)*x_bar_ij)^2);

lines3d(theta, x_bar ,fn,...
        'ydraw', 0,...
        'scale',1,...
        'border',50,...
        'axis',[-5  5 -5  5]);
view(V);
    
%% Bayesian Diagramz
figure

% P(theta|x_bar) 
subplot(2,2,1)

fn =  @(theta_ij,x_bar_ij)normpdf(theta_ij,n*x_bar_ij/(1+n),1/(1+n));

lines3d(theta,x_bar,fn,...
        'ycol', @(X)[0, 0, exp(-(X.^2)/10)],...
        'xdraw', 0,...
        'border',50,...
        'axis',[-5  5 -5  5]);

view(V);

subplot(2,2,2)

%  L(theta,delta(x))*P(theta|x_bar) 
fn =  @(theta_ij,x_bar_ij)((theta_ij - (1)*x_bar_ij)^2)*normpdf(theta_ij,n*x_bar_ij/(1+n),1/(1+n));

lines3d(theta, x_bar, fn,...
        'ycol', @(Y)[0, 0, exp(-((1*Y).^2)/10)],...
        'xdraw', 0,...
        'yfunction',@(X)5*exp(-(1*X).^2),...
        'ysum', 1,...
        'border',50,...
        'axis',[-5  5 -5  5]);

view(V);

subplot(2,2,3)

% L(theta,delta(x))*P(theta|x_bar)*P(theta)
fn =  @(theta_ij,x_bar_ij)((theta_ij - (1)*x_bar_ij)^2)*normpdf(x_bar_ij,theta_ij,1/n)*normpdf(theta_ij,0,1);

lines3d(theta, x_bar, fn,...
        'ycol', @(Y)[0, 0, exp(-((1*Y).^2)/10)],...
        'xdraw', 0,...
        'ysum', 1,...
        'border',50,...
        'axis',[-5  5 -5  5]);

view(V);

subplot(2,2,4)

% L(theta,delta)
fn =  @(theta_ij,x_bar_ij)((theta_ij - (1)*x_bar_ij)^2);

lines3d(theta, x_bar, fn,...
        'xdraw', 0,...
        'scale',1,...
        'border',50,...
        'axis',[-5  5 -5  5]);

view(V);

end

function [L] = lines3d( X, Y, f , varargin )
%LINES3D - Draw a 3d function, f, as a series of line segments.
%
% Syntax:  lines3d(x,y,f,....)
%
% Inputs:
%   x - matrix of x values (produced by meshgrid)
%   y - matrix of y values (produced by meshgrid)
%   f - function with two parameters returning a single value to be
%   calculated.
% 
% Optional Parameters:
%   border - truncate "border" number of pixels when doing the plot. This
%   function is useful if you wish to draw the sum beyond the current 
%   plotting range
%   xdraw/ydraw - set to 0 to not draw lines along the x axis
%   xcol/ycol - function defining the color gradient of the lines
%   yfunction/xfunction - plot an "extra" function on the borders.
%   scale - adjust the plotting range of the z values by adjusting the
%   value of scale
%   sumscale - adjust the sum by a factor of sumscale
%   xsum/ysum - set to 1 to permit drawing of the sum of the values in x
%   and y respectively (this can be intepreted as integrating the line in
%   question using quardrature)
%   axis - x and y axis
%
% Outputs:
%    L - height matrix of function evaluated at f(x(i),y(j))
%
% Example: 
%   [x,y] = meshgrid(-1:0.01:1)
%   lines3d(x,y,@(x,y) (x+y)^2)
%
%
% this may look strange, but computing normpdf directly is no faster or
% more stable than exp(normpdfln).


% Draw a 3d function, f, as a series of line segments.

p = inputParser;   % Create an instance of the inputParser class.
p.addOptional('border', 1 );
p.addOptional('xdraw', 1);
p.addOptional('ydraw', 1);
p.addOptional('xcol', @(c)[0, 0, 0] );
p.addOptional('ycol', @(c)[0, 0, 0] );
p.addOptional('yfunction', 0);
p.addOptional('xfunction', 0);
p.addOptional('sumscale', 1/16);
p.addOptional('scale',2);
p.addOptional('xsum',0);
p.addOptional('ysum',0);
p.addOptional('axis',[]);

p.parse(varargin{:});
p.Results;


[n,m] = size(X);

L = zeros(n,m);

for i = 1:n
    for j = 1:m
       L(i,j) = f(X(i,j),Y(i,j));
    end
end

sumXY = sum(L);
sumYX = sum(L,2)';

% We may wish to integrate beyond the boundaries of the matrix. To do so,
% I generate matrix larger than the displayed matrix, and sum over the
% larger matrix, but crop out 

k = p.Results.border;
L = L(k:end-k,k:end-k);
X = X(k:end-k,k:end-k);
Y = Y(k:end-k,k:end-k);
sumXY = sumXY(k:end-k);
sumYX = sumYX(k:end-k);

hold on
grid off

if ~isempty(p.Results.axis)
    axis([p.Results.axis,...   
          0    p.Results.scale*max(max(L))])
end

% New size, after crop
[n,] = size(X);

xcol = p.Results.xcol;
ycol = p.Results.ycol;

for i = fliplr(1:4:n)

    if p.Results.xdraw
        color = xcol(X(1,i));
        plot3(Y(:,i), X(:,i), L(:,i),'Color',color,'LineWidth',1)
    end
    
    if p.Results.ydraw
        color = ycol(Y(i,1));
        plot3(X(:,i), Y(:,i), L(i,:),'Color',color,'LineWidth',1)
    end
    
end

sumscale = p.Results.sumscale;

if p.Results.xsum
    plot3(X(:,end), Y(:,1), sumXY*sumscale ,'b','LineWidth',2);
end

if p.Results.ysum
    plot3(Y(:,1), X(:,end), sumYX*sumscale ,'b','LineWidth',2);
end

if strcmp(class(p.Results.yfunction), 'function_handle')
    frontf = p.Results.yfunction;
    plot3(Y(:,1), X(:,1), frontf(Y(:,1)),'b','LineWidth',2);
end

if strcmp(class(p.Results.xfunction), 'function_handle')
   sidef = p.Results.xfunction;
   plot3(X(:,1), Y(:,1), sidef(X(1,:)),'b','LineWidth',2);
end

end