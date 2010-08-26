function model = mixDiscreteCreate(T, mixweight)
%% Create a mixture of discrete distributions model
% See also mixDiscreteFit
model = structure(T, mixweight); 
model.modelType = 'mixDiscrete';
end