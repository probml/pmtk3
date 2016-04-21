# Demo of probabilistic line search applied to a noisy 2d function
# Demo is based on "run_minimal_example.m" from
# https://ei.is.tuebingen.mpg.de/uploads_file/attachment/attachment/242/probLineSearch.zip

import numpy as np        
import optim
from prob_line_search import *

x1min = -5
x1max = 10    # x-limits for plotting
x2min = 0
x2max = 15      # y-limits for plotting
func = optim.branin 
x_global_min = [np.pi, 2.275]
#x_global_min = [-pi, 12.275], x_global_min = [9.42478, 2.475]
x0 = np.array([5, 13]) 

ax = np.linspace(x1min, x1max, 200);
ay = np.linspace(x2min, x2max, 200);
X, Y = np.meshgrid(ax, ay); 
XX = [X(:),Y(:)]; #
Z = F(XX);
Z = reshape(Z,size(X));
subplot(1, 1, 1); hold on;
if min(Z(:)) < 0
    Z = Z - min(Z(:));
end

gray_r = 1-gray;
colormap(gray_r)
imagesc([x1min, x1max],[x2min, x2max], log(Z)); axis tight; colorbar;
plot(path(1,:), path(2,:), '-gx')
plot(x_global_min(1), x_global_min(2), 'ro', 'markersize', 10)

  w0s = np.linspace(w0_range[0], w0_range[1], 100)
    w1s = np.linspace(w1_range[0], w1_range[1], 100)
    w0_grid, w1_grid = np.meshgrid(w0s, w1s)
    lossvec = np.vectorize(loss_fun)
    z = lossvec(w1_grid, w0_grid)
    cs = ax.contour(w1s, w0s, z)
    ax.clabel(cs)
    ax.plot(params_opt[1], params_opt[0], 'rx', markersize=14)
    ax.plot(params_true[1], params_true[0], 'k+', markersize=14)
    