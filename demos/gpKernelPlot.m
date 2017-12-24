%% GP kernel plots from David Duvenaud's thesis
% Code from https://github.com/duvenaud/phd-thesis/tree/master/code
% Modified by Kevin Murphy

function plot_structure_examples(seed)

% A script to make a series of plots demonstrating how structure can be
% reflected in a kernel.
%
% This version updated to be more amenable to tiny plots.
%
% David Duvenaud
% Jan 2013

if nargin < 1; seed = 1; end
randn('state',seed);
rand('state',seed);

savefigs = true;
figpath = '../figures/grammar/structure_examples/';

%addpath(genpath('utils'))

% Make up some data
%X = [ -2 -1 0 1 2 ]' .* 2;
%y = [ -1 1 1 -0.8 1.1  ]';
X = [ 1 2 3 ]' .* 2;
y = [ 1 2 4 ]';
y = y - mean(y);
N = length(X);

n_samples = 4;

n_xstar = 201;
xrange = linspace(-10, 10, n_xstar)';
post_xrange = linspace(-3, 10, n_xstar)';
x0 = 1;
numerical_noise = 1e-5;
model_noise = 2;

se_length_scale = 2.5;
se_outout_var = 2;
se_kernel = @(x,y) se_outout_var*exp( - 0.5 * ( ( x - y ) .^ 2 ) ./ se_length_scale^2 );

lin_output_var = 0.5;
lin_kernel = @(x,y) lin_output_var*( (x + 1) .* (y + 1) );
poly_lin_kernel = @(x,y) lin_output_var*( 1 + x .* y  );

quad_output_var = 0.5;
quad_kernel = @(x,y) quad_output_var*( (1 +  x .*y).^2 );


% Use GPML toolbox
%hyps = [log(1), log(quad_output_var)];
%quad_kernel_gpml = @(x,y) diag(covPoly(2, hyps, x(:), y(:)));

%https://github.com/duvenaud/warped-mixtures/blob/master/gpml/cov/covMaterniso.m
% Matern covariance function with nu = d/2 and isotropic distance measure.
% Let r = |x - x'|
% matern_kernel d = s2f * f( sqrt(d)*r ) * exp(-sqrt(d)*r)
% with f(t)=1 for d=1 % exponential (OU)
% f(t)=1+t for d=3 
% f(t)=1+t+t^2/3 for d=5.
s2f = 1; % output_var
f1 = @(t) 1;
f3 = @(t) 1 + t;
f5 = @(t) 1 + t.*(1+t/3);
m = @(t,f) f(t).*exp(-t); 
 
matern_kernel_1 = @(x,y) m(sqrt(1) * abs(x-y), f1);
matern_kernel_3 = @(x,y) m(sqrt(3) * abs(x-y), f3);
matern_kernel_5 = @(x,y) m(sqrt(5) * abs(x-y), f5);



longse_length_scale = 20;
longse_output_var = 10;
longse_kernel = @(x,y) longse_output_var*exp( - 0.5 * ( ( x - y ) .^ 2 ) ./ longse_length_scale^2 );

shortse_length_scale = 0.5;
shortse_output_var = 0.5;
shortse_kernel = @(x,y) shortse_output_var*exp( - 0.5 * ( ( x - y ) .^ 2 ) ./ shortse_length_scale^2 );

medse_length_scale = 10;
medse_output_var = 5;
medse_kernel = @(x,y) medse_output_var*exp( - 0.5 * ( ( x - y ) .^ 2 ) ./ medse_length_scale^2 );


per_length_scale = 1;
per_period = 4;
per_output_var = 1.1;
per_kernel = @(x,y) per_output_var*exp( - 2 * ( sin(pi*( x - y )./per_period) .^ 2 ) ./ per_length_scale^2 );

cos_period = 4;
cos_output_var = 1.1;
cos_kernel = @(x,y) cos_output_var*cos( 2 * pi * (  x - y )./cos_period);

wn_output_var = 1.1;
wn_kernel = @(x,y) wn_output_var*double(  x == y );

rq_length_scale = 2.5;
rq_outout_var = 2;
rq_alpha = 1.1;
rq_kernel = @(x,y) rq_outout_var*( 1 + ( x - y ) .^ 2 ./ (2*rq_alpha*rq_length_scale^2 )).^-rq_alpha;

c_kernel = @(x, y) ones(size(x*y));

se_plus_lin = @(x,y) se_kernel(x, y) + lin_kernel(x, y);
se_plus_per = @(x,y) se_kernel(x, y) + per_kernel(x, y);
se_times_lin = @(x,y) se_kernel(x, y) .* lin_kernel(x, y);
se_times_per = @(x,y) se_kernel(x, y) .* per_kernel(x, y);
lin_times_per = @(x,y) lin_kernel(x, y) .* per_kernel(x, y);
lin_plus_per = @(x,y) lin_kernel(x, y) + per_kernel(x, y);
lin_times_lin = @(x,y) lin_kernel(x, y) .* lin_kernel(x, y);
longse_times_per = @(x,y) longse_kernel(x, y) .* per_kernel(x, y);
longse_plus_per = @(x,y) longse_kernel(x, y) + per_kernel(x, y);
longse_times_lin = @(x,y) longse_kernel(x, y) .* lin_kernel(x, y);
longse_plus_se = @(x,y) longse_kernel(x, y) + se_kernel(x, y);
shortse_plus_medse = @(x,y) shortse_kernel(x, y) + medse_kernel(x, y);

if 0
kernel_names = {'se_kernel', 'lin_kernel', 'per_kernel', 'longse_kernel', ...
            'se_plus_lin', 'se_plus_per', 'se_times_lin', 'se_times_per', ...
            'lin_times_per', 'lin_plus_per', 'lin_times_lin', ...
            'longse_times_per', 'longse_plus_per', 'longse_times_lin', ...
            'rq_kernel','c_kernel'};
end
kernel_names = { 'lin_kernel', 'quad_kernel', ...
    'se_kernel', 'rq_kernel',...
    'per_kernel', 'cos_kernel', 'wn_kernel'};

kernel_names = {'lin_kernel', 'poly_lin_kernel'};


% Automatically build kernel functions from function names.
for i = 1:numel(kernel_names)
    kernels{i} = eval(kernel_names{i});
end

%color_ixs = [ 1, 2, 3, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 4 ]; 
color_ixs = repmat(10, 1, numel(kernels));

if 1
% plot the kernels.
for k = 1:numel(kernels)
    %figure(k); clf;
    figure;
    cur_kernel = kernels{k};
    kvals = bsxfun(cur_kernel, xrange, x0 );
    kernel_plot( xrange, kvals, color_ixs(k) );
    title(safeStr(kernel_names{k}), 'fontsize', 10)
    if savefigs
        printPmtkFigure(sprintf('GP%s', kernel_names{k}), 'png');
        %save2pdf([ figpath, kernel_names{k}, '.pdf'], gcf, 600, true);
    end
    pause(0.01);
    drawnow;
end
end

% Plot draws from the kernels.
for k = 1:numel(kernels)
    %figure(10 + k); clf;
    figure;
    K = bsxfun(kernels{k}, xrange', xrange ) + eye(n_xstar).*numerical_noise; % Evaluate prior.
    %L = chol(K);
    samples = mvnrnd( zeros(size(xrange)), K, n_samples)';
    samples = samples + repmat((1:n_samples) * 5 - 10, n_xstar, 1);
    samples_plot( xrange, samples, [1:n_samples] );
    title(safeStr(kernel_names{k}), 'fontsize', 10)
    if savefigs
        printPmtkFigure(sprintf('GP%sSamples', kernel_names{k}), 'png');
        %save2pdf([ figpath, kernel_names{k} '_draws_s', int2str(seed), '.pdf'], gcf, 600, true);
    end
    pause(0.01);
    drawnow;    
end

if 0
% Plot posterior dists of the kernels.
for k = 1:numel(kernels)
    figure(20 + k); clf;
    cur_kernel = kernels{k};
    K = bsxfun(cur_kernel, X, X' ) + eye(N).*model_noise; % Evaluate prior.
    weights = K \ y;
    posterior = @(x)(bsxfun(cur_kernel, post_xrange, X') * weights); % Construct posterior function.
    posterior_variance = @(x)diag(bsxfun(cur_kernel, post_xrange', post_xrange) - (bsxfun(cur_kernel, X', xrange) / K * bsxfun(cur_kernel, xrange', X)));
    posterior_plot( post_xrange, posterior(post_xrange), posterior_variance(post_xrange), X, y );

    if savefigs
        %save2pdf([ figpath, kernel_names{k} '_post.pdf'], gcf, 600, true);
    end
    pause(0.01);
    drawnow;    
end
end
end


function kernel_plot( xrange, vals, color_ix )
    % Figure settings.
    lw = 2;
    fontsize = 10;
 
    plot(xrange, vals, 'Color', colorbrew(color_ix), 'LineWidth', lw); hold on;
       
    if all( vals >= 0 ); lowlim = 0; else lowlim = min(vals) * 1.05; end
    % Make plot prettier.  
    xlim([min(xrange), max(xrange)]);
    ylim([min(lowlim,0), max(vals) * 1.05]);
    set( gca, 'XTick', [ 0 ] );
    set( gca, 'yTick', [ 0 ] );
    set( gca, 'XTickLabel', '' );
    %set( gca, 'yTickLabel', '' );
 %   xlabel( '$x - x''$', 'Fontsize', fontsize );
    %xlabel(' ');
    %ylabel( '$k(x, 0)$', 'Fontsize', fontsize );
    set(get(gca,'XLabel'),'Rotation',0,'Interpreter','latex', 'Fontsize', fontsize);
    set(get(gca,'YLabel'),'Rotation',90,'Interpreter','latex', 'Fontsize', fontsize);
    %set(gca, 'TickDir', 'out')
    set(gca, 'Box', 'off');
    set(gcf, 'color', 'white');
    set(gca, 'YGrid', 'off');
    
    %set_fig_units_cm( 4,3 );
end

function samples_plot( xrange, samples, color_ix )
    % Figure settings.
    lw = 2;
    fontsize = 10;
 
    for i = 1:size(samples, 2);
        plot(xrange, samples(:,i), 'Color', colorbrew(color_ix(i)), 'LineWidth', lw); hold on;
    end
    
    % Make plot prettier.  
    xlim([min(xrange), max(xrange)]);
    set( gca, 'XTick', [ 0 ] );
    %set( gca, 'yTick', [ 0 ] );
    set( gca, 'yTick', [] );
    set( gca, 'XTickLabel', '' );
    set( gca, 'yTickLabel', '' );
    %xlabel( '$x$', 'Fontsize', fontsize );
    %ylabel( '$f(x)$', 'Fontsize', fontsize );
    set(get(gca,'XLabel'),'Rotation',0,'Interpreter','latex', 'Fontsize', fontsize);
    set(get(gca,'YLabel'),'Rotation',90,'Interpreter','latex', 'Fontsize', fontsize);
    %set(gca, 'TickDir', 'out')
    set(gca, 'Box', 'off');
    set(gcf, 'color', 'white');
    set(gca, 'YGrid', 'off');
    
    %set_fig_units_cm( 4,3 );
end


function posterior_plot( xrange, f, v, X, y )
    % Figure settings.
    lw = 2;
    fontsize = 10;
    opacity = 1;
    fake_opacity = 0.1;
    
    jbfill( xrange', ...
            f' + 2.*sqrt(v)', ...
            f' - 2.*sqrt(v)', ...
            colorbrew(2).^fake_opacity, 'none', 1, opacity); hold on;
    plot( xrange, f, '-', 'Linewidth', lw, 'Color', colorbrew(2)); hold on;

    % Plot data.
    plot( X, y, 'kx', 'Linewidth', lw, 'MarkerSize', 6); hold on;

    % Make plot prettier.
    width = abs(min(xrange) - max(xrange));  % Widen xlim slightly.
    xlim([min(xrange) - width/50, max(xrange) + width/50]);
    %set( gca, 'XTick', [ -1 0 1 ] );
    %set( gca, 'yTick', [ 0 1 ] );
    set( gca, 'XTickLabel', '' );
    %set( gca, 'yTickLabel', '' );
  %  xlabel( '$x$', 'Fontsize', fontsize );
    ylabel( '$f(x)$', 'Fontsize', fontsize );
    set(get(gca,'XLabel'),'Rotation',0,'Interpreter','latex', 'Fontsize', fontsize);
    set(get(gca,'YLabel'),'Rotation',90,'Interpreter','latex', 'Fontsize', fontsize);
    %set(gca, 'TickDir', 'out')
    set(gca, 'Box', 'off');
    set(gcf, 'color', 'white');
    set(gca, 'YGrid', 'off');
    ylim([-5, 5])
    
    set_fig_units_cm( 4,3 );
end
