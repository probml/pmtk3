%% Fit a Gaussian Mixture Model using over-relaxed EM
% We use synthetic data sampled from a GMM
% PMTKauthor Krishna Nand Keshava Murthy
%%

% This file is from pmtk3.googlecode.com

ntrials = 2;
for trial = 1:ntrials
    setSeed(trial);
    D = 15; N = 5000;
    Clusters = 10;
    mu = rand(D,Clusters);
    mixweight = normalize(rand(1, Clusters));
    Sigma = zeros(D,D,Clusters);
    for k=1:Clusters
        Sigma(:,:,k) = randpd(D);
    end
    trueModel = mixGaussCreate(mu, Sigma,  mixweight); 
    %trueModel = mixModelCreate(condGaussCpdCreate(mu, Sigma), 'gauss', Clusters, mixweight);
    %[fullData] = mixModelSample(trueModel, N);
    [fullData] = mixGaussSample(trueModel, N);
    Ks = [5 10];
    verbose = true;
    eta = {[], 1, 1.25, 2, 5}; % over-relaxation increase factor
    nmethods = length(eta);
    llHist  = cell(1, nmethods);
    models = cell(1, nmethods);
    names = {'EM', 'OR(1)', 'OR(1.25)', 'OR(2)', 'OR(5)'};
    [styles, colors, symbols] =  plotColors();
    for k = 1:length(Ks)
        K = Ks(k);
        for m=1:nmethods
            tic
            %[models{m}, llHist{m}] = mixModelFit(fullData, K, 'gauss',...
            %    'overRelaxFactor',eta{m}, 'verbose', verbose); 
            if isempty(eta{m})
              [models{m}, llHist{m}] = mixGaussFit(fullData, K, ...
                'verbose', verbose);
            else
               [models{m}, llHist{m}] = mixGaussFitOverrelaxedEM(fullData, K, ...
                 eta{m}, 'verbose', verbose);
            end
            tim(m) = toc;
        end
        figure
        hold on
        for m=1:nmethods
            str= sprintf('%s%s%s', colors(m), symbols(m), styles{m});
            plot(llHist{m}, str, 'LineWidth',2,'MarkerSize',10)
            legendStr{m} = sprintf('%s (%5.3f)', names{m}, tim(m));
        end
        legend(legendStr, 'location', 'southeast');
        xlabel('iterations'); ylabel('loglik')
        title(sprintf('K=%d, D=%d, N=%d', K, D, N));
    end
    %%
end
