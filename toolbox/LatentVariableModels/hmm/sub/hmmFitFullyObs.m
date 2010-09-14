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
%
%%

% This file is from pmtk3.googlecode.com

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
A        = countTransitions(Z, nstatesZ);
model.A  = normalize(A + transPrior-1, 2);
seqidx   = cumsum([1, cellfun(@(seq)size(seq, 2), Z')]);
pi       = rowvec(histc(Zstacked(seqidx(1:end-1)), 1:nstatesZ));
model.pi = normalize(pi + rowvec(piPrior) - 1);
d      = size(Ystacked, 2);
switch lower(type)
    case 'gauss'
        
        emission = condGaussCpdCreate(ones(d, nstatesZ), ones(d, d, nstatesZ), 'prior', emissionPrior);
        model.emission = emission.fitFn(emission, Zstacked, Ystacked);
        
    case 'student'
        
        emission = condStudentCpdCreate(ones(d, nstatesZ), ones(d, d, nstatesZ), 'prior', ones(1, nstatesZ), emissionPrior);
        model.emission = emission.fitFn(emission, Zstacked, Ystacked);
        
    case 'discrete'
        
        nstatesY = max(Ystacked);
        emission = condDiscreteProdCpdCreate(ones(nstatesZ, nstatesY, d), 'prior', emissionPrior);
        model.emission = emission.fitFn(emission, Zstacked, Ystacked);
        
    case 'mixgausstiedcpd'
        error('fitting a condMixGaussTiedCpd given fully obs data is not yet supported');
    otherwise
        error('%s is not a supported emission type', type);
end
model.type = type;
model.piPrior = piPrior;
model.transPrior = transPrior;

end
