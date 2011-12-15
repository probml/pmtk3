%% Figure 1 from Figueiredo'07,  "Gradient projection for sparse reconstruction"
% PMTKauthor Figueiredo
% PMTKurl http://www.lx.it.pt/~mtf/GPSR/
% PMTKmodified Kevin Murphy
% PMTKslow
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
% n is the original signal length
n = 2^12;

% k is number of observations to make
k = 2^10;

% number of spikes to put down
% n_spikes = floor(.01*n);
n_spikes = 160;


% random +/- 1 signal
f = zeros(n,1);
q = randperm(n);
f(q(1:n_spikes)) = sign(randn(n_spikes,1));
%f(q(1:n_spikes)) = randn(n_spikes,1);

% measurement matrix
R = randn(k,n);

% orthonormalize rows
R = orth(R')';


% noisy observations
sigma = 0.01;
y = R*f + sigma*randn(k, 1);

% regularization parameter
tau = 0.1*max(abs(R'*y));

[x_l1_ls,status,history] = l1_ls(R,y,2*tau,0.01);

w = x_l1_ls;
aw = abs(w);
zz = find(abs(w) <= 0.01*max(aw));
ndx = setdiff(1:n, zz);
wdebiased = zeros(n,1);
X = R;
%wdebiased(ndx) = pinv(X(:,ndx))*y;
wdebiased(ndx) = X(:,ndx)\y;
wfull = X'*y; % since X is orthogonal %pinv(X)*y; % X'*y; % X\y;


wsparse = w;
wdeb = wdebiased;
wls = wfull;

figure
scrsz = get(0,'ScreenSize');
set(gca,'Position',[10 scrsz(4)*0.1 0.9*scrsz(3)/2 3*scrsz(4)/4])
subplot(4,1,1)
plot(f,'LineWidth',1.1)
top = max(f(:));
bottom = min(f(:));
v = [0 n+1 bottom-0.05*(top-bottom)  top+0.05*((top-bottom))];
set(gca,'FontName','Times')
set(gca,'FontSize',14)
title(sprintf('Original (D = %g, number of nonzeros = %g)',n,n_spikes))
%axis(v)
set(gca,'ylim',[-1 1])

subplot(4,1,2)
plot(wsparse,'LineWidth',1.1)
set(gca,'FontName','Times')
set(gca,'FontSize',14)
axis(v)
title(sprintf('L1 reconstruction (K0 = %g, lambda = %5.3g, MSE = %5.3g)',...
    k,tau,(1/n)*norm(wsparse-f)^2))

subplot(4,1,3)
plot(wdeb,'LineWidth',1.1)
set(gca,'FontName','Times')
set(gca,'FontSize',14)
top = max(f(:));
bottom = min(f(:));
v = [0 n+1 bottom-0.15*(top-bottom)  top+0.15*((top-bottom))];
%axis(v)
set(gca,'ylim',[-1 1])
title(sprintf(...
    'Debiased (MSE = %0.4g)',(1/n)*norm(wdeb-f)^2))

subplot(4,1,4)
plot(wls,'LineWidth',1.1)
set(gca,'FontName','Times')
set(gca,'FontSize',14)
title(sprintf('Minimum norm solution (MSE = %0.4g)',(1/n)*norm(wls-f)^2))
top = max(wls(:));
bottom = min(wls(:));
v = [0 n+1 bottom-0.15*(top-bottom)  top+0.15*((top-bottom))];
%axis(v)
set(gca,'ylim',[-1 1])


printPmtkFigure('sparseSensingDemo')
