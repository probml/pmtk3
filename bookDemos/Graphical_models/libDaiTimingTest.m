function libDaiTimingTest
%%
setSeed(0);
nnodes = 600; 
maxNstates = 2;
maxFanIn = 2; 
maxFanOut = 3; 
model = mkRndFactorGraph(nnodes, maxNstates, maxFanIn, maxFanOut); 



if 0
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
