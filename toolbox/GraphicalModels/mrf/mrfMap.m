function map = mrfMap(mrf, varargin)
%% Find the mode, (map assignment)
% Optional named args are the same as for mrfInferNodes
% This uses jtree.
%%

% This file is from pmtk3.googlecode.com

[clamped, softEv, localEv] = process_options(varargin, ...
    'clamped', [], ...
    'softev' , [], ...
    'localev', []);
localFacs = {};
if ~isempty(localEv)
    localFacs = softEvToFactors(localEvToSoftEv(mrf, localEv));
end
if ~isempty(softEv)
    localFacs = [localFacs(:); colvec(softEvToFactors(softEv))];
end
cg = mrf.cliqueGraph; 
if isfield(mrf, 'jtree')
    jtree     = jtreeSliceCliques(mrf.jtree, clamped);
else
    doSlice   = true;
    cg.Tfac   = addEvidenceToFactors(cg.Tfac, clamped, doSlice);
    cg.nstates(find(clamped)) = 1; %#ok
    jtree     = jtreeCreate(cg);
end
jtree         = jtreeAddFactors(jtree, localFacs);
map           = jtreeFindMap(jtree);
if ~isempty(clamped)
    map(find(clamped)) = nonzeros(clamped); %#ok 
end
end
