function VANdemo()

%{
nbins = 10;
minx = 0.1;
maxx = 2.5;
x = linspace(minx, maxx, 20)
y = quantize(x, nbins, minx, maxx)
%} 

seed = 310;

max_iter = 50;

ss_newton = 1;
v0_newton = [-3.2 0]';

ss_van_scale = 0.5;
ss_van_mu = 1;
num_mc_samples = 1000;
v0 = [-3.2 1.5]';
scale_0 = 1./((v0(2)).^2);


%% Init

func = @my_sinc;
x = -4:.01:3;
f_orig = func(x);


%% Newton

rng(seed);
fn = []; vn = []; vn(:,1) = v0_newton;
for t = 1:max_iter

    xt = vn(1,t);
    [ft,gt,ht] = func(xt);
    fn(t) = ft;

    vn(1,t+1) = vn(1,t) - ss_newton*(gt./ht);
    vn(2,t+1) = 0;

end

xt = vn(1,max_iter+1);
[ft,gt,ht] = func(xt);
fn(max_iter+1) = ft;



%% VAN

scale = scale_0;
rng(seed);
f = []; v = []; v(:,1) = v0;
for t = 1:max_iter
    
    mu_t = v(1,t);
    sig_t = v(2,t);

    % draw from q
    e = randn(1,num_mc_samples);
    x_t = mu_t + sig_t*e;

    % evaluate function
    [fx,gx,hx] = func(x_t);
    f(t) = func(mu_t);

    % compute gradients
    g_mu = mean(gx);
    g_s2 = mean(hx);

    scale = scale + ss_van_scale*(g_s2);
    v(1,t+1) = v(1,t) - ss_van_mu*(g_mu./scale);
    v(2,t+1) = 1./sqrt(scale);
    %[g_mu; g_s2];

end


xt = v(1,max_iter+1);
[ft,gt,ht] = func(xt);
f(max_iter+1) = ft;


%% Plot

%points_to_plot = [1 10 15 17 20 22 25 27 30 35 40 50];
points_to_plot = 1:5:50; % linspace(1, 50, 10)

% f1 = subplot(3,1,1);]
figure
%subaxis(3,1,1, 'Spacing', spacing, 'PaddingLeft', pad_left, 'PaddingRight', pad_right, 'PaddingTop', pad_top, 'PaddingBottom', pad_bottom, 'Margin', margin);
plot(x, f_orig,'b-', 'linewidth', 1.5, 'MarkerFaceColor', [1,1,1]);
hold on;
%plot([v(1,points_to_plot);v(1,points_to_plot)],[f(points_to_plot);-ones(1,length(points_to_plot))],'r:','linewidth',1)
hold on;
plot(v(1,points_to_plot), f(points_to_plot),'ro', 'linewidth', 1, 'MarkerFaceColor', [1,1,1])
plot(vn(1,points_to_plot), fn(points_to_plot),'kx', 'markersize', 12, 'MarkerFaceColor', [1,1,1])

set(gca, 'FontSize', 12)
ylabel('Function $f(\theta)$','FontSize',12, 'interpreter','latex')
xlabel('$\theta$','FontSize',12, 'interpreter','latex')

printPmtkFigure('VAN-1d')


% f2 = subplot(3,1,2);
figure;
%subaxis(3,1,2, 'Spacing', spacing, 'PaddingLeft', pad_left, 'PaddingRight', pad_right, 'PaddingTop', pad_top, 'PaddingBottom', pad_bottom, 'Margin', margin);
e = randn(1,1000);
mu = x;
sig = 0.001:0.1:2.5;
for i = 1:length(mu)
   for j = 1:length(sig)
      x1 = mu(i) + sig(j)*e;
      %sig0 = 1;
      L(i,j) = mean(func(x1));% - log(sig(j)) + 0.5*(sig(j)/sig0)^2 - mu(i).^2/(sig0^2);
   end
end
contourf(mu, sig, L', 30);
hold on;

factors = [0.71 0.8 0.65 0.83 0.775 0.79 0.72 0.76 0.79 0.7 0.6];
for i = 1:(length(points_to_plot)-1)
    x1 = v(1,points_to_plot(i));
    x2 = x1 + factors(i)*(v(1,points_to_plot(i+1)) - x1);
    y1 = v(2,points_to_plot(i));
    y2 = y1 + factors(i)*(v(2,points_to_plot(i+1)) - y1);
    [xf, yf]=ds2nfu([x1,x2],[y1,y2]);
    annotation(gcf,'arrow', xf,yf,'color','r','headstyle','plain', 'headlength', 3, 'headwidth', 3);
end
plot(v(1,points_to_plot), v(2,points_to_plot),'ro', 'linewidth', 1, 'MarkerFaceColor', [1,1,1]);

set(gca, 'FontSize', 12)
ylabel('$\sigma$','FontSize',12, 'interpreter','latex')
xlabel('$\mu$','FontSize',12, 'interpreter','latex')
printPmtkFigure('VAN-2d')


% f3 = subplot(3,1,3);
figure;
plot_dist_for = 1:5:50; %[1 20 35 40 50];
%subaxis(3,1,3, 'Spacing', spacing, 'PaddingLeft', pad_left, 'PaddingRight', pad_right, 'PaddingTop', pad_top, 'PaddingBottom', pad_bottom_last, 'Margin', margin);
max_y = 0;
for i = 1:length(plot_dist_for)
    y = normpdf(x,v(1,plot_dist_for(i)),v(2,plot_dist_for(i)));
    max_y = max(max_y,max(y));
    frac = 1-i/length(plot_dist_for);
    plot(x,y,'Color',[frac,frac,frac], 'linewidth', 1);
    hold on;
    %plot(v(1,plot_dist_for(i)), 0,'ro', 'linewidth', 0.5, 'MarkerFaceColor', [1,1,1])
end
%plot([v(1,plot_dist_for);v(1,plot_dist_for)],[zeros(1,length(plot_dist_for));max_y*ones(1,length(plot_dist_for))],'r:','linewidth',1)
ylim([0,max_y]);
set(gca, 'FontSize', 12)
xticks(-4:3)
xlabel('$\theta$','FontSize',12, 'interpreter','latex')
ylabel('Distribution $q(\theta)$','FontSize',12, 'interpreter','latex')
printPmtkFigure('VAN-density')

end



function [f,g,h] = my_sinc(x)
% return gradient and hessian of 
% -sin(pi*(x-1))/ (pi*(x-1))
xx = x; % x-1;
   sinpx = sin(pi*xx);
   cospx = cos(pi*xx);
   f = -sinpx./(pi*xx);
   g = sinpx./(pi*xx.^2) - cospx./xx;
   h = -2*sinpx./(pi*xx.^3) + 2*cospx./(xx.^2) + pi*sinpx./xx;
end

function y = quantize(x, N, xMin, xMax)
      y = floor( N * log(x/xMin) / log(xMax/xMin) ) ;
 end
   

