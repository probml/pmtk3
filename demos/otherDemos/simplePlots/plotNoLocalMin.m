%% Illustration of a function without a distinct local minimum
% Ascher notes p4, fig 2.4 on p8
%%

% This file is from pmtk3.googlecode.com

f = @(x,y) (x(:,1).^3 - x(:,1).^2 .* x(:,2) + 2 * x(:,2).^2);
[x, y] = meshgrid(-10:1:10);
z = reshape(f([x(:), y(:)]), size(x));
figure();
surf(x,y,z);
printPmtkFigure('ascherNoLocalMin'); 
figure();
contour(x,y,z,[-100 -1:0.1:1 100]);

