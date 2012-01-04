%% Rosenbrock constrained optimization demo
%
%%

% This file is from pmtk3.googlecode.com

function demoRosenConstrained()

% minimize 2d rosenbrock st x1^2 + x^2 <= 1
% Example from p1-8 of Mathworks Optimization Toolbox manual

requireOptimToolbox

xstart = [-1 2];
 % Hessian is ignored by quasi-Newton so we use interior point
opts = optimset('DerivativeCheck', 'on', 'Display', 'off', 'GradObj', 'on', 'Algorithm', 'interior-point');

% basic usage - numerical gradient for constraints
opts = optimset(opts, 'GradConstr', []);
[x fval exitflag output] = fmincon(@rosen2d, xstart, [], [], [], [], [], [], @constr, opts);
fprintf('fcount = %d\n\n\n', output.funcCount)

% analytic gradient for constraints
opts = optimset(opts, 'GradConstr', 'on');
[x fval exitflag output] = fmincon(@rosen2d, xstart, [], [], [], [], [], [], @constrgrad, opts);
fprintf('fcount = %d\n\n\n', output.funcCount)


% analytic Hessian for objective and constraints (see p4-17, p11-42 for syntax)
% If you don't use interior-point, the method defaults to quasi-Newton
% which obviously does not need a Hessian
opts = optimset(opts,  'GradConstr', 'on', 'Algorithm', 'interior-point', ...
  'Hessian','user-supplied','HessFcn',@hess);
[x fval exitflag output] = fmincon(@rosen2d, xstart, [], [], [], [], [], [], @constrgrad, opts);
fprintf('fcount = %d\n\n\n', output.funcCount)

end

function [c, ceq] = constr(x)
c = x(1)^2 + x(2)^2 - 1;
ceq = [];
end

function [c, ceq, cgrad, ceqgrad] = constrgrad(x)
c = x(1)^2 + x(2)^2 - 1;
ceq = 0;
cgrad = 2*x(:); % column j is gradient wrt j'th constraint
ceqgrad = zeros(2,1);
end

function H = hess(x, lambda)
[fx,gx,Hx] = rosen2d(x(:)');
H = Hx + lambda.ineqnonlin*2*eye(length(x));
end
