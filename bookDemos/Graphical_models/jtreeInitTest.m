%% Simple test of junction tree construciton 

loadData('alarmNetwork'); 
dgm = dgmCreate(alarmNetwork.G, alarmNetwork.CPT, 'infEngine', 'none');
factors = cpds2Factors(dgm.CPDs, dgm.G, dgm.CPDpointers);
fg = factorGraphCreate(factors, dgm.G);

for m=1:2
  tic
  for i=1:20
    jtree{m} = jtreeInit(fg, 'method', m);
  end
  t(m) = toc
end
assert(isequal(jtree{1},jtree{2}))

