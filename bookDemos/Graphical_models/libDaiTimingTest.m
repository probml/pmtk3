function libDaiTimingTest
%% Compare speed of libDAI's jtree code to our own
% libDAI is currently about 10 times faster, but gives normalizaton errors
% when nnodes > about 580
setSeed(0);
nnodes = 580; 
maxNstates = 2;
maxFanIn = 2; 
maxFanOut = 3; 
model = mkRndFactorGraph(nnodes, maxNstates, maxFanIn, maxFanOut); 



if 1
tic;
marginalsJT = junctionTree(model, num2cell(1:nnodes));
toc;
end


tic;
psi = cellfuncell(@convertToLibFac, model.Tfac);
[logZ, q, md, qv] = dai(psi, 'JTREE', '[updates=HUGIN]');
mld = cellfuncell(@convertToPmtkFac, qv);
toc; 

end


function lfac = convertToLibFac(mfac)
lfac.Member = mfac.domain - 1;
lfac.P = mfac.T;
end

function mfac = convertToPmtkFac(lfac)
    mfac = tabularFactorCreate(lfac.P, lfac.Member+1); 
end
