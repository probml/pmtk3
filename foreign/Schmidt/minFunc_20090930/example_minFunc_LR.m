clear all

nInst = 500;
nVars = 100;
X = [ones(nInst,1) randn(nInst,nVars-1)];
w = randn(nVars,1);
y = sign(X*w);
flipInd = rand(nInst,1) > .9;
y(flipInd) = -y(flipInd);

w_init = zeros(nVars,1);
funObj = @(w)LogisticLoss(w,X,y);

fprintf('Running Hessian-Free Newton w/ numerical Hessian-Vector products\n');
options.Method = 'newton0';
minFunc(@LogisticLoss,w_init,options,X,y);
pause;

fprintf('Running Preconditioned Hessian-Free Newton w/ numerical Hessian-Vector products (Diagonal preconditioner)\n');
options.Method = 'pnewton0';
options.precFunc = @LogisticDiagPrecond;
minFunc(@LogisticLoss,w_init,options,X,y);
pause;

fprintf('Running Preconditioned Hessian-Free Newton w/ numerical Hessian-Vector products (L-BFGS preconditioner)\n');
options.Method = 'pnewton0';
options.precFunc = [];
minFunc(@LogisticLoss,w_init,options,X,y);
pause;

fprintf('Running Hessian-Free Newton w/ analytic Hessian-Vector products\n');
options.Method = 'newton0';
options.HvFunc = @LogisticHv;
minFunc(@LogisticLoss,w_init,options,X,y);
pause;

fprintf('Running Preconditioned Hessian-Free Newton w/ analytic Hessian-Vector products (Diagonal preconditioner)\n');
options.Method = 'pnewton0';
options.HvFunc = @LogisticHv;
options.precFunc = @LogisticDiagPrecond;
minFunc(@LogisticLoss,w_init,options,X,y);
pause;

fprintf('Running Preconditioned Hessian-Free Newton w/ analytic Hessian-Vector products (L-BFGS preconditioner)\n');
options.Method = 'pnewton0';
options.precFunc = [];
options.HvFunc = @LogisticHv;
minFunc(@LogisticLoss,w_init,options,X,y);
pause;