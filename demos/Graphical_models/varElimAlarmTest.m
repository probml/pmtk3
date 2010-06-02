%% Test variable elimination on the Alarm Network
%
%%

alarm = loadData('alarmNetwork');
CPT = alarm.CPT;
G   = alarm.G; 
n   = numel(CPT); 
Tfac = cell(n, 1); 
for i=1:numel(CPT)
    family = [parents(G, i), i];
    Tfac{i} = tabularFactorCreate(CPT{i}, family); 
end
domain = 1:n;
model = structure(Tfac, G, domain); 
%% Try some arbitrary queries 
p1_10Given13eq2 = variableElimination(model, 1:10, 13, 2);
p33 = variableElimination(model, 33);
p9And12Given11And15eq2And4 = variableElimination(model, [9 12], [11 15], [2 4]);
% Compare against value from PMTK1
assert(approxeq(p9And12Given11And15eq2And4.T, [0.9405 0.0095; 0.0495 0.0005])); 