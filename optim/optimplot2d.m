function stop = optimplot2d(x, optimValues, state)
% plots the current point of a 2-d optimization
stop = false;
switch state
  case 'init'
    hold on
  case 'iter'
    plot(x(1),x(2),'.');
    text(x(1)+0.15, x(2), num2str(optimValues.iteration));
    drawnow
  case 'done'
    hold off
end

