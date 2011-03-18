function logZ = dgmLogprob(dgm, varargin)
%% Logprob of data
% If every node is clamped, we just multiply all the CPDs.
% If we have missing data, we run inference.
% If using batch mode, all nodes must be fully observed
% and must have tabular CPDs.
%
% INPUTS
%
% Batch mode 
% obs(n, t) = value of node t in case n
%
% Single casem mode:
% clamped(t) = 0 if unclamped, =k if clamped to state k
% softev(k,t)  = p(Xt=k)
% localev(d,t) = data for node Xt
% 
%%

% This file is from pmtk3.googlecode.com

[obs, clamped, softEv, localEv] = process_options(varargin, ...
    'obs', [], ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []);

Nnodes = dgm.nnodes;
if ~isempty(dgm.toporder) && ~isequal(dgm.toporder, 1:Nnodes)
  %fprintf('warning: dgmInferQueryis permuting data columns\n');
  if ~isempty(softEv), softEv = softEv(:, dgm.toporder); end
  if ~isempty(clamped), clamped = clamped(dgm.toporder); end
  if ~isempty(localEv), localEv = localEv(:, dgm.toporder); end
  if ~isempty(obs), obs = obs(:, dgm.toporder); end
end

if isfield(dgm, 'factors')
  factors = dgm.factors;
else
  factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
end
doSlice = false;

if ~isempty(obs)
  [Ncases Nnodes] = size(obs);
  %{
  % This method is very slow since it iterates over cases
  % and uses cellfun to iterate over nodes
   logZ = zeros(1, Ncases);
  for n=1:Ncases
    fac = addEvidenceToFactors(factors, obs(n,:), doSlice); 
    logZ(n)= sum(log(cellfun(@(f)nonzeros(f.T), fac) + eps));
  end
  %}
  ll  = zeros(Ncases, Nnodes);
  for j=1:Nnodes
    ps = parents(dgm.G, j);
    e = dgm.CPDpointers(j); % equivalence class for node j 
    CPT = dgm.CPDs{e}.T;
    sz = dgm.CPDs{e}.sizes;
    data = [obs(:,ps) obs(:,j)];
    ndx = subv2ind(sz, data); % convert each row into an index
    ll(:,j) = log(CPT(ndx)+eps); 
  end
  logZ = sum(ll, 2);
  return
end

if ~isempty(clamped) && all(clamped(:))
    fac = addEvidenceToFactors(factors, clamped, doSlice); 
    logZ = sum(log(cellfun(@(f)nonzeros(f.T), fac) + eps));
    return; 
end

% otherwise run inference
query = {};
%[~, logZ] = dgmInferQuery(dgm, query, varargin{:}); %#ok
[~, logZ] = dgmInferQuery(dgm, query, 'softev', softEv, 'localev', localEv); 

%{
% The old code (pre 29Sep10) assumed the use of jtree
localFacs = {}; 
if ~isempty(localEv)
    localFacs = softEvToFactors(localEvToSoftEv(dgm, localEv));
end
if ~isempty(softEv)
    localFacs = [localFacs(:); colvec(softEvToFactors(softEv))];
end

G = dgm.G;
if isfield(dgm, 'jtree')
    jtree = jtreeSliceCliques(dgm.jtree, clamped);
else
    doSlice = true;
    factors = cpds2Factors(dgm.CPDs, G, dgm.CPDpointers);
    factors = addEvidenceToFactors(factors, clamped, doSlice);
    nstates = cellfun(@(f)f.sizes(end), factors); 
    jtree   = jtreeCreate(cliqueGraphCreate(factors, nstates, G));
end
[jtree, logZlocal] = jtreeAddFactors(jtree, localFacs);
[jtree, logZ] = jtreeCalibrate(jtree);
logZ = logZ + logZlocal; 
%}

end
