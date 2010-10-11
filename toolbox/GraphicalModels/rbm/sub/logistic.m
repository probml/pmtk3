%Sigmoid function
function[y] = logistic(x)
y = 1./(1 + exp(-x));