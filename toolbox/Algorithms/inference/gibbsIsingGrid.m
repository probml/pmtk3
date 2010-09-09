function avgX = gibbsIsingGrid(J, CPDs, logprobFn, visVals, varargin)
%% Gibbs sampling in a 2d Ising grid
% J = coupling (edge) strength
% CPDs{1}=p(y|x=-1), CPDs{2}=p(y|x=+1)
% logprobFn is a handle to a function that will be called with
% logprobFn(CPDS{i}, visVals(:))
% visVals should be an m*n matrix
% Returns p(X(i,j)=1|y)
%
%PMTKauthor Brani Vidakovic
%PMTKmodified Kevin Murphy, Matt Dunham
%%

% This file is from pmtk3.googlecode.com

[Nsamples, Nburnin, progressFn, maxIter] = process_options(...
    varargin, 'Nsamples', [], 'Nburnin', 0, ...
    'progressFn', [], 'maxIter', []);

if isempty(Nsamples), Nsamples = maxIter; end

[M,N] = size(visVals);
Npixels = M*N;
localEvidence = zeros(Npixels, 2);
for k=1:2
    localEvidence(:,k) = exp(logprobFn(CPDs{k}, visVals(:)));
end
%% init
[junk, guess] = max(localEvidence, [], 2);  % start with best local guess
X = ones(M, N);
offState = 1; onState = 2;
X((guess==offState)) = -1;
X((guess==onState)) = +1;

%% And go...
avgX = zeros(size(X));
S = (Nsamples + Nburnin);
for iter =1:S
    % select a pixel at random
    %ix = ceil( N * rand(1) ); iy = ceil( M * rand(1) );
    for ix=1:N
        for iy=1:M
            pos = iy + M*(ix-1);
            neighborhood = pos + [-1,1,-M,M];
            neighborhood(([iy==1,iy==M,ix==1,ix==N])) = [];
            % compute local conditional
            wi = sum( X(neighborhood) );
            p1  = exp(J*wi) * localEvidence(pos,onState);
            p0  = exp(-J*wi) * localEvidence(pos,offState);
            prob = p1/(p0+p1);
            if rand < prob
                X(pos) = +1;
            else
                X(pos) = -1;
            end
        end
    end
    if (iter > Nburnin) %&& (mod(iter, thin)==0)
        avgX = avgX+X;
    end
    if ~isempty(progressFn)
        feval(progressFn, X, iter);
    end
end
avgX = avgX/Nsamples;
end
