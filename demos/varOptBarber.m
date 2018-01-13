function varOptBarber()

% Variational Optimisation
% https://davidbarber.github.io/blog/2017/04/03/variational-optimisation/

% f(x) is a simple quadratic objective function (linear regression sq loss)
% p(x|theta) is a Gaussian


function out=E(W,x,y)
out=mean(0.5*(W*x-y).^2);
end

function [g,G]=gradE(W,x,y)
G=repmat(W*x-y,size(W,2),1).*x;
g=sum(G,2)/size(G,2);
g=g';
end


% Create the dataset:
N=10; % Number of datapoints
D=2; % Dimension of the data
W0=randn(1,D)/sqrt(D); % true linear regression weight
x=randn(D,N); % inputs
y=W0*x; % outputs

% plot the error surface:
w1=linspace(-5,5,50); w2=w1;
for i=1:length(w1)
    for j=1:length(w2)
        Esurf(i,j)=E([w1(i) w2(j)],x,y);
    end
end
figure;
h=surf(w1,w2,Esurf); set(h,'LineStyle','none');  view(0,90); hold on

Winit=[-4 4]; % initial starting point for the optimisation

% standard gradient descent:
Nloops=150; % number of iterations
eta=0.1; % learning rate
W=Winit;
for i=1:Nloops
    plot3(W(2),W(1),E(W,x,y)+0.1,'y.','markersize',20);
    W=W-eta*gradE(W,x,y);
end

% Variational Optimisation with fixed variance
Nsamples=10; % number of samples
sd=5; % initial standard deviation of the Gaussian
%beta=2*log(sd); % parameterise the standard variance
mu=Winit; % initial mean of the Gaussian
%sdvals=[sd];
for i=1:Nloops
    plot3(mu(2),mu(1),E(mu,x,y)+0.1,'r.','markersize',20);
    EvalVarOpt(i)=E(mu,x,y); % error value
    xsample=repmat(mu,Nsamples,1)+sd*randn(Nsamples,D); % draw samples
    
    g=zeros(1,D); % initialise the gradient for the mean mu
    %gbeta=0; % initialise the gradient for the standard deviation (beta par)
    for j=1:Nsamples
        f(j) = E(xsample(j,:),x,y); % function value (error)
        g=g+(xsample(j,:)-mu).*f(j)./(sd*sd);
        %gbeta=gbeta+0.5*f(j)*(exp(-beta)*sum((xsample(j,:)-mu).^2)-D);
    end
    g = g./Nsamples;
    %gbeta=gbeta/Nsamples;
    
    mu=mu-eta*g; % Stochastic gradient descent for the mean
    %beta=beta-0.01*gbeta; % Stochastic gradient descent for the variance par

        
    %sd=sqrt(exp(beta));
    %sdvals=[sdvals sd];
end





% Variational Optimisation:
Nsamples=10; % number of samples
sd=5; % initial standard deviation of the Gaussian
beta=2*log(sd); % parameterise the standard variance
mu=Winit; % initial mean of the Gaussian
sdvals=[sd];
for i=1:Nloops
    plot3(mu(2),mu(1),E(mu,x,y)+0.1,'g.','markersize',20);
    EvalVarOpt(i)=E(mu,x,y); % error value
    xsample=repmat(mu,Nsamples,1)+sd*randn(Nsamples,D); % draw samples
    
    g=zeros(1,D); % initialise the gradient for the mean mu
    gbeta=0; % initialise the gradient for the standard deviation (beta par)
    for j=1:Nsamples
        f(j) = E(xsample(j,:),x,y); % function value (error)
        g=g+(xsample(j,:)-mu).*f(j)./(sd*sd);
        gbeta=gbeta+0.5*f(j)*(exp(-beta)*sum((xsample(j,:)-mu).^2)-D);
    end
    g = g./Nsamples;
    gbeta=gbeta/Nsamples;
    
    mu=mu-eta*g; % Stochastic gradient descent for the mean
    beta=beta-0.01*gbeta; % Stochastic gradient descent for the variance par
    % comment the line above to turn off variance adaptation
        
    sd=sqrt(exp(beta));
    sdvals=[sdvals sd];
end

%title('yellow=SGD, red=VO(fixed \sigma), green=VO')
printPmtkFigure('varOptBarberSurface')

figure; plot(sdvals);
xlabel('iteration')
ylabel('estimated \sigma')
printPmtkFigure('varOptBarberSD')

end


