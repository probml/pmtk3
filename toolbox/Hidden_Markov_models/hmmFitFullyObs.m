function model =  hmmFitFullyObs(Z, Y, type, varargin)
%% Fit a fully observed HMM via mle/map
%
% Z       - a cell array of observations of the discrete Markov backbone;
%           each observation j is 1-by-seqLength(j).
% 
% Y        - a cell array of emission observations; each observation j is
%            d-by-seqLength(j) (where d is always 1 if type = 'discrete')
%
% type     - one of {'gauss', 'discrete'}
%
% See hmmFit for details on priors
%%
Z        = cellwrap(Z); 
Y        = cellwrap(Y); 
Zstacked = cell2mat(Z')'; % sum(seqLength)-by-1
Ystacked = cell2mat(Y')'; % sum(seqLength)-by-d
nstatesZ = max(Zstacked); 

[piPrior, transPrior, emissionPrior] = process_options(varargin , ...
    'piPrior'                   , 2*ones(1, nstatesZ)           , ...
    'transPrior'                , 2*ones(nstatesZ, nstatesZ)    , ...
    'emissionPrior'             , []);

if diff(size(transPrior))
    transPrior = repmat(rowvec(transPrior), nstatesZ, 1);
end
A        = accumarray([Zstacked(1:end-1), Zstacked(2:end)], 1); 
model.A  = normalize(A + transPrior-1, 2); 
seqidx   = cumsum([1, cellfun(@(seq)size(seq, 2), Z')]);
pi       = histc(Zstacked(seqidx(1:end-1)), 1:nstatesZ)';
model.pi = normalize(pi + rowvec(piPrior) - 1);       
switch lower(type)
    case 'gauss'
        
        d = size(Ystacked, 2); 
        if isempty(emissionPrior)
            emissionPrior.mu    = zeros(1, d);
            emissionPrior.Sigma = 0.1*eye(d);
            emissionPrior.k     = 0.01;
            emissionPrior.dof   = d + 1; 
        end
        mu = zeros(d, nstatesZ);
        Sigma = zeros(d, d, nstatesZ); 
        for s=1:nstatesZ
           m              = gaussFit(Ystacked(Zstacked == s, :), emissionPrior); 
           mu(:, s)       = m.mu(:);  
           Sigma(:, :, s) = m.Sigma; 
        end
        model.emission = condGaussCpdCreate(mu, Sigma); 
        model.d = d; 
        
    case 'discrete'
        
        nstatesY = max(Ystacked); 
        if isempty(emissionPrior)
            emissionPrior = 2*ones(nstatesZ, nstatesY);
        end
        T = zeros(nstatesZ, nstatesY); 
        for s=1:nstatesZ
            data = Ystacked(Zstacked == s);
            T(s, :) = histc(data, 1:nstatesY); 
        end
        T = normalize(T + emissionPrior - 1, 2);  
        model.emission = tabularCpdCreate(T); 
        model.d = 1; 
        
    otherwise
        error('%s is not a supported emission type', type); 
end

model.type = type; 
end