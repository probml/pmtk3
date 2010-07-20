function model =  hmmFitFullyObs(Z, Y, type, varargin)
%% Fit a fully observed HMM via mle
%
% Z       - a cell array of observations of the discrete Markov backbone;
%           each observation j is 1-by-seqLength(j).
% 
% Y        - a cell array of emission observations; each observation j is
%            d-by-seqLength(j) (where d is always 1 if type = 'discrete')
%
% type     - one of {'gauss', 'discrete'}
%
% TODO   (add support for priors)
%%

Z        = cellwrap(Z); 
Y        = cellwrap(Y); 
Zstacked = cell2mat(Z')'; % sum(seqLength)-by-1
Ystacked = cell2mat(Y')'; % sum(seqLength)-by-d
nstatesZ = max(Zstacked); 
model.A  = normalize(accumarray([Zstacked(1:end-1), Zstacked(2:end)], 1), 2); 

seqidx   = cumsum([1, cellfun(@(seq)size(seq, 2), Z')]);
model.pi = normalize(histc(Zstacked(seqidx(1:end-1)), 1:nstatesZ))';
      
switch lower(type)
    case 'gauss'
        
        d = size(Ystacked, 2); 
        mu = zeros(d, nstatesZ);
        Sigma = zeros(d, d, nstatesZ); 
        for s=1:nstatesZ
           data           = Ystacked(Zstacked == s, :); 
           mu(:, s)       = mean(data, 1)'; 
           Sigma(:, :, s) = cov(data); 
        end
        model.emission = condGaussCpdCreate(mu, Sigma); 
        model.d = d; 
        
    case 'discrete'
        
        nstatesY = max(Ystacked); 
        T = zeros(nstatesZ, nstatesY); 
        for s=1:nstatesZ
            data = Ystacked(Zstacked == s);
            T(s, :) = histc(data, 1:nstatesY); 
        end
        T = normalize(T, 2); 
        model.emission = tabularCpdCreate(T); 
        model.d = 1; 
        
    otherwise
        error('%s is not a supported emission type', type); 
end

model.type = type; 
end