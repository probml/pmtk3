clear all

nInstances = 500;
nVars = 100;

X = randn(nInstances,nVars);
w = randn(nVars,1).*(rand(nVars,1) > .5);
y = X*w + randn(nInstances,1);

t = 10;
active_old = LassoActiveSet(X,y,t,'verbose',0);

% Solve with and without warm-starting
t = t+1;
fprintf('Running with cold start\n');
active = LassoActiveSet(X,y,t);

fprintf('\n\nRunning with warm start\n');
active2= LassoActiveSet(X,y,t,'w0',active_old);

max_difference_between_cold_and_warm_start_solutions = norm(active-active2,inf)