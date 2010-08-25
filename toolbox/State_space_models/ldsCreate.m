function model = ldsCreate(A, C, b, Q, R, m1, Sigma1)
%% Construct an lds model

model = structure(A, C, b, Q, R, m1, Sigma1); 
model.modelType = 'lds'; 

end