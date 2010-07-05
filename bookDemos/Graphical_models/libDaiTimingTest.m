function libDaiTimingTest
%% Compare speed of libDAI's jtree code to our own
% libDAI is currently about 8 times faster, but gives normalizaton errors
% when nnodes > 600 with seed = 0
% Requires libDai (add the libdai/matlab directory to the matlab path)
setSeed(0);
nnodes = 500; 
maxNstates = 3;
maxFanIn = 3; 
maxFanOut = 3; 
model = mkRndFactorGraph(nnodes, maxNstates, maxFanIn, maxFanOut); 

tic;
psi = cellfuncell(@convertToLibFac, model.Tfac);
[logZ, q, md, qv] = dai(psi, 'JTREE', '[updates=HUGIN]');
mld = cellfuncell(@convertToPmtkFac, qv);
toc; 


if 1
tic;
marginalsJT = junctionTree(model, num2cell(1:nnodes));
toc;
end




end


function lfac = convertToLibFac(mfac)
lfac.Member = mfac.domain - 1;
lfac.P = mfac.T;
end

function mfac = convertToPmtkFac(lfac)
    mfac = tabularFactorCreate(lfac.P, lfac.Member+1); 
end
