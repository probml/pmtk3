function dgm = dgmTrainFullyObs(dgm, data, varargin)
%% Fit a dgm via mle/map given fully observed data
%
% See dgmTrain
%%

% This file is from pmtk3.googlecode.com

[clamped, localEv] = process_options(varargin , 'clamped', [], 'localev', []); 
if ~isempty(localEv) && ndims(localEv) < 3 && dgm.nnodes > 1
   localEv = insertSingleton(localEv, 1);  
end
nnodes = dgm.nnodes; 
if isempty(clamped)
    clamped = sparsevec([], [], nnodes);
end
%% fit CPDs
CPDs     = dgm.CPDs;
pointers = dgm.CPDpointers;
nnodes   = dgm.nnodes;
G        = dgm.G;
if isequal(pointers, 1:numel(CPDs)) % no paramter tying
    for i=1:nnodes
        CPD = CPDs{i};
        if clamped(i);
            CPD = cpdClamp(CPD, clamped(i));
        else
            dom = [parents(G, i), i];
            CPD = CPD.fitFn(CPD, data(:, dom));
        end
        CPDs{i} = CPD;
    end
else % handle parameter tying
    eqc = computeEquivClasses(pointers);
    nobs = size(data, 1);
    for i = 1:numel(CPDs)
        CPD = CPDs{i};
        eclass = eqc{i};
        if any(clamped(eclass));
            val = clamped(eclass(1));
            CPD = cpdClamp(CPD, val);
        else
            domSz = numel(parents(G, eclass(1))) + 1;
            X     = zeros(nobs*numel(eclass), domSz); % combine data from the same eq class
            for j = 1:numel(eclass)
                k         = eclass(j);
                dom       = [parents(G, k), k];
                ndx       = (j-1)*nobs+1:(j-1)*nobs+nobs;
                X(ndx, :) = data(:, dom);
            end
            CPD = CPD.fitFn(CPD, X);
        end
        CPDs{i} = CPD;
    end
end
dgm.CPDs = CPDs;
%% fit localCPDs
if ~isempty(localEv)
    [nobs, d, nnodes] = size(localEv); %#ok
    localCPDs         = dgm.localCPDs;
    localPointers     = dgm.localCPDpointers;
    for i = 1:numel(localCPDs)
        lCPD = localCPDs{i};
        
        if isempty(lCPD)
            continue
        end
        
        eclass = findEquivClass(localPointers, i);
        
        if any(clamped(eclass))
            continue 
        end
        
        N             = nobs*numel(eclass);
        Y             = cell2mat(localEv2HmmObs(localEv(:, :, eclass))')'; % Y is now Nxd
        missing       = any(isnan(Y), 2); % ok to have missing leaves
        Y(missing, :) = [];
        
        if isempty(Y)
            continue
        end % unobserved leaf
        
        Z            = reshape(data(:, eclass)', [N, 1]);
        Z(missing)   = [];
        lCPD         = lCPD.fitFn(lCPD, Z, Y);
        localCPDs{i} = lCPD;
    end
    dgm.localCPDs = localCPDs;
end
end
