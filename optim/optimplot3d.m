function stop = optimplot3d(x, optimValues, state)
% plots the current point of a 2-d otimization
stop = false;
hold on;
plot3(x(1),x(2),optimValues.fval,'.');
drawnow

