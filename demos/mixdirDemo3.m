%% Biosequence analysis Demo
%   t  = locn
%   Z(t)|w ~ Discrete(w(:)), k in {1,2,3,4,k}
%   theta(:,t) | Z(t)=k ~ Dir(alpha(:,k))
%   x(i,t) | theta(:,t) ~ Discrete(theta(:,t))

% This file is from pmtk3.googlecode.com



%% Data generation
setSeed(1);
Nseq = 10;
Nlocn = 15;
Nletters = 4;
Nmix = 4;
pfg = 0.30;

mixweights = [pfg/Nmix*ones(1, Nmix) 1-pfg]; % 5 states
z = sampleDiscrete(mixweights, 1, Nlocn);
alphas = 1*ones(Nletters, Nmix);
for i=1:Nmix
    alphas(i, i) = 20; % reflects purity
end
alphas(:, Nmix+1) = ones(Nletters, 1); % state 5 is background

theta = zeros(Nletters, Nlocn);
data = zeros(Nseq, Nlocn);
chars = ['a' 'c' 'g' 't' '-']';
dataStr = repmat('-',Nseq , Nlocn);
for t=1:Nlocn
    theta(:,t) = dirichlet_sample(alphas(:,z(t)), 1)';
    data(:,t) = sampleDiscrete(theta(:,t), Nseq, 1);
    dataStr(:, t) = chars(data(:, t));
end

%dataStr
for i=1:Nseq
    for t=1:Nlocn
        fprintf('%s ', dataStr(i,t));
    end
    fprintf('\n');
end
%%


W = seqlogoPmtk(dataStr); 
printPmtkFigure('seqlogo');



%%
zStr = chars(z);
figure();
image_rgb(data); title('location')
set(gca,'xtick',1:Nlocn);
str = cell(Nlocn, 1); 
for t=1:Nlocn
    str{t} = sprintf('%d', z(t));
end
set(gca,'xticklabel',str);
ylabel('sample')

%% Inference
nvec = zeros(Nletters, Nlocn);
postZ = zeros(Nmix+1, Nlocn); 
for t=1:Nlocn
    prior = mixweights;
    nvec(:,t) = hist(data(:,t), 1:Nletters)';
    loglik = zeros(1, Nmix+1); 
    for k=1:Nmix+1
        loglik(k) = logmarglikDirichletMultinom(nvec(:, t)', alphas(:, k)');
    end
    logprior = log(prior);
    numer = logprior + loglik;
    postZ(:, t) = exp(numer - logsumexp(numer, 2));
    %postZ(:, t) = exp(numer - logsumexp(numer(:))',2);
end
prob = nvec./repmat(sum(nvec,1),4,1);
figure()
bar(matrixEntropy(prob));
title('entropy vs position')

postC = sum(postZ(1:4,:));
figure();
stem(postC); 
title('p(C(t)=1|Dt)');
hold on
for t=1:Nlocn
    if z(t)<5
        % if conserved, mark with x
        plot(t, postC(t), 'rx', 'markersize', 14);
    end
end
set(gca, 'xlim', [0 Nlocn+1]);
placeFigures();
