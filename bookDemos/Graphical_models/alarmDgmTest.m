%% Test inference on the Alarm Network
%
%%

dgm = mkAlarmDgm(); % default infEng is jtree
nodeBelJtree = dgmInferNodes(dgm); 
dgm.infEngine = 'varelim';
nodeBelVelim = dgmInferNodes(dgm);
dgm.infEngine = 'libdaiJtree'; 
nodeBelLibdai = dgmInferNodes(dgm); 
for i=1:numel(nodeBelJtree)
   assert(approxeq(nodeBelJtree{i}.T, nodeBelVelim{i}.T));  
   assert(approxeq(nodeBelVelim{i}.T, nodeBelLibdai{i}.T));  
end



% 
% 
% alarm = loadData('alarmNetwork');
% CPT = alarm.CPT;
% G   = alarm.G; 
% n   = numel(CPT); 
% Tfac = cell(n, 1); 
% for i=1:numel(CPT)
%     family = [parents(G, i), i];
%     Tfac{i} = tabularFactorCreate(CPT{i}, family); 
% end
% model = structure(Tfac, G); 
% %% Try some arbitrary queries 
% evidence = sparsevec(13, 2, n);
% p1_10Given13eq2 = variableElimination(model, 1:10, evidence);
% p33 = variableElimination(model, 33);
% evidence = sparsevec([11 15], [2 4], n); 
% p9And12Given11And15eq2And4 = variableElimination(model, [9 12], evidence);
% % Compare against value from PMTK1
% assert(approxeq(p9And12Given11And15eq2And4.T, [0.9405 0.0095; 0.0495 0.0005])); 