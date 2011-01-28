function [zest, xest, zsamples, xsamples,  w] = pfSlds(N, par, y, u, resamplingScheme)
% particle filtering for switching linear dynamical system
% See Doucet, Gordon, Krishnamurthy
% "Particle filers for state estimation of Jump Markov Lienar Systems", 2001.
%
% N: num samples
% par: parameters of SLDS (se below) 
% y: ny*T
% u: nu*T
% resamplingScheme: 1 residual, [default 2 deterministic], 3 multinomial
%
% Returns
% xest: nx*T (mean)
% zest: nz*T (histogram)
% zsamples: T*N
% xsamples: nx*T*N
% w: T*N
%
% Parameters: x=cts state, z=discrete state, y=obs
% A: nx*nx*nz
% B: nx*nx*nz
% C: ny*nx*nz
% D: ny*ny*nz
% E: nx*nx*nz
% F: nx*1*nz
% G: ny*1*nz

%PMTKauthor Nando de Freitas
%PMTKmodified Kevin Murphy
%PMTKdate 2001
%PMTKurl http://www.cs.ubc.ca/~nando/software/demo_rbpf_gauss.tar

if nargin < 5, resamplingScheme = 2; end


 [nz,T] = size(y);
 [n_y, n_x, n_z] = size(par.C);
 
% INITIALISATION:
% ==============
z_pf = ones(1,T,N);            % These are the particles for the estimate
                               % of z. Note that there's no need to store
                               % them for all t. We're only doing this to
                               % show you all the nice plots at the end.
z_pf_pred = ones(1,T,N);       % One-step-ahead predicted values of z.
x_pf = 10*randn(n_x,T,N);      % These are the particles for the estimate x.
x_pf_pred = x_pf;  
y_pred = 10*randn(n_y,T,N);    % One-step-ahead predicted values of y.
w = ones(T,N);                 % Importance weights.
initz = 1/n_z*ones(1,n_z);    
xest = zeros(n_x,T); %KPM 
zest = zeros(n_z,T); % KPM

for i=1:N,
  z_pf(:,1,i) = length(find(cumsum(initz')<rand))+1; 
end;


for t=2:T,    
  %fprintf('PF :  t = %i / %i  \r',t,T); fprintf('\n');  

  % SEQUENTIAL IMPORTANCE SAMPLING STEP:
  % =================================== 
  for i=1:N,
    % sample z(t)~p(z(t)|z(t-1))
    z_pf_pred(1,t,i) = length(find(cumsum(par.T(z_pf(1,t-1,i),:)')<rand))+1;
    % sample x(t)~p(x(t)|z(t|t-1),x(t-1))
    x_pf_pred(:,t,i) = par.A(:,:,z_pf_pred(1,t,i)) * x_pf(:,t-1,i) + ...
                       par.B(:,:,z_pf_pred(1,t,i))*randn(n_x,1) + ...
                       par.F(:,:,z_pf_pred(1,t,i))*u(:,t); 
  end;
  % Evaluate importance weights.
  for i=1:N,
    y_pred(:,t,i) =  par.C(:,:,z_pf_pred(1,t,i)) * x_pf_pred(:,t,i) + ...
                     par.G(:,:,z_pf_pred(1,t,i))*u(:,t); 
    Cov = par.D(:,:,z_pf_pred(1,t,i))*par.D(:,:,z_pf_pred(1,t,i))'; 
    w(t,i) =  (det(Cov)^(-0.5))*exp(-0.5*(y(:,t)-y_pred(:,t,i))'* ...
				    pinv(Cov)*(y(:,t)-y_pred(:,t,i))) + 1e-99;
  end;  
  w(t,:) = w(t,:)./sum(w(t,:));       % Normalise the weights.

  
  % SELECTION STEP:
  % ===============
  if resamplingScheme == 1
    outIndex = residualR(1:N,w(t,:)');        % Higuchi and Liu.
  elseif resamplingScheme == 2
    outIndex = deterministicR(1:N,w(t,:)');   % Kitagawa.
  else  
    outIndex = multinomialR(1:N,w(t,:)');     % Ripley, Gordon, etc.  
  end;
  z_pf(1,t,:) = z_pf_pred(1,t,outIndex);
  x_pf(:,t,:) = x_pf_pred(:,t,outIndex);
  xest(:,t) = mean(squeeze(x_pf(:,t,:)), 2); % KPM - unweighted mean
  zest(:,t) = normalize(hist(squeeze(z_pf(1,t,:)), 1:n_z)); % KPM
end;   % End of t loop.

zsamples = squeeze(z_pf); % (1,t,:) -> (t,:)
xsamples = x_pf;

end

