% Demonstrate group lasso
% Needs the SpaRSA code from http://www.lx.it.pt/~mtf/SpaRSA
% This is based on demo_group_L2 and demo_group_Linf
%PMTKauthor Mario Figueiredo
%PMTKmodified Kevin Murphy

for signal_type = 0:1
  
setSeed(1);

% n is the original signal length
n = 2^12;

% k is number of observations to make
k = 2^10;

% number of groups with activity 
n_active = 8;

n_groups = 64;
size_groups = n / n_groups;

raux = randperm(n_groups);
actives = raux(1:n_active);

groups = ceil([1:n]'/size_groups);

f = zeros(n,1);


  
if signal_type==0
  % gaussian signal
  for i=1:n_active
    f(find(groups==actives(i))) = ...
      randn(size(f(find(groups==actives(i)))));
  end
else
  % uniform signal
  for i=1:n_active
    f(find(groups==actives(i))) = ...
      ones(size(f(find(groups==actives(i)))));
  end
end

% measurement matrix
R = randn(k,n);

% orthonormalize rows
R = orth(R')';

hR = @(x) R*x;
hRt = @(x) R'*x;

% noisy observations
sigma = 0.02;
y = hR(f) + sigma*randn(k,1);

% regularization parameter
tau = 0.1*max(abs(R'*y));


%  group l2 norm 
psi = @(x,tau) group_vector_soft(x,tau,groups);
phi = @(x)     group_l2norm(x,groups);

L12_tau = tau*5;
[x_L12_biased, x_L12_debiased]= ...
    SpaRSA(y,hR, L12_tau,...
    'Psi',psi,...
    'Phi',phi,...
    'Monotone',1,...
    'Debias',1,...
    'AT',hRt,... 
    'Initialization',0,...
    'StopCriterion',1,...
    'ToleranceA',0.0001, ...
    'MaxiterA',100);
  
  
% L1 inf norm
 

psi = @(x,tau) group_L2_Linf_shrink(x,tau,groups);
phi = @(x)     group_linf_norm(x,groups);

Linf_tau = tau*5;
[x_Linf_biased, x_Linf_debiased]= ...
    SpaRSA(y,hR, Linf_tau,...
    'Psi',psi,...
    'Phi',phi,...
    'Monotone',1,...
    'Debias',1,...
    'AT',hRt,... 
    'Initialization',0,...
    'StopCriterion',1,...
    'ToleranceA',0.001, ...
    'MaxiterA',1000);
  
% L1
L1_tau = tau*5;
[x_L1_biased, x_L1_debiased]= ...
         SpaRSA(y, hR, L1_tau,...
         'Debias',1,...
         'AT',hRt,... 
         'True_x',f,...
         'Monotone',1,...
         'Initialization',0,...
         'StopCriterion',3,...
       	 'ToleranceA',0.01,...
         'ToleranceD',0.0001);

for debiased=1:1
  
  if debiased
    x_L1 = x_L1_debiased;
    x_L12 = x_L12_debiased;
    x_Linf = x_Linf_debiased;
  else
    x_L1 = x_L1_biased;
    x_L12 = x_L12_biased;
    x_Linf = x_Linf_biased;
  end
  
nr = 4; nc = 1;
figure
scrsz = get(0,'ScreenSize');
set(gcf,'Position',[10 scrsz(4)*0.1 0.9*scrsz(3)/2 3*scrsz(4)/4])
subplot(nr,nc,1)
plot(f,'LineWidth',1.1)
top = max(f(:));
bottom = min(f(:));
v = [0 n+1 bottom-0.05*(top-bottom)  top+0.05*((top-bottom))];
set(gca,'FontName','Times')
set(gca,'FontSize',14)
title(sprintf('Original (D = %g, number groups = %g, active groups = %g)',...
  n,n_groups,n_active))
axis(v);


  
subplot(nr, nc, 2)
plot(x_L1,'LineWidth',1.1)
set(gca,'FontName','Times')
set(gca,'FontSize',14)
top = max(f(:));
bottom = min(f(:));
v = [0 n+1 bottom-0.15*(top-bottom)  top+0.15*((top-bottom))];
axis(v)
title(sprintf(...
    'Standard L1 (debiased %d, tau = %5.3g, MSE = %0.4g)',...
    debiased, L1_tau, (1/n)*norm(x_L1-f)^2));

  
subplot(nr, nc, 3)
plot(x_L12,'LineWidth',1.1)
set(gca,'FontName','Times')
set(gca,'FontSize',14)
axis(v)
title(sprintf('Block-L2 (debiased %d, tau = %5.3g, MSE = %5.3g)',...
    debiased, L12_tau, (1/n)*norm(x_L12-f)^2));


  
subplot(nr, nc, 4)
plot(x_Linf,'LineWidth',1.1)
set(gca,'FontName','Times')
set(gca,'FontSize',14)
axis(v)
title(sprintf('Block-Linf (debiased %d, tau = %5.3g, MSE = %5.3g)',...
    debiased, Linf_tau, (1/n)*norm(x_Linf-f)^2));

  drawnow

end % for debiased

end % for signal_type


