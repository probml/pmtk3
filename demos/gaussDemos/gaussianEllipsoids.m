%% Visualize the Projection of 3D Gaussian Ellipsoids onto the 2D Plain

C = {[2 4 10] [12 0 10] [20 0 10]};
R = {[6 3 3] [3 6 3] [3 3 6]};
npoints = 25;
nellipsoids = length(C);
D = repmat(createStruct({'X', 'Y', 'Z'}), 1, nellipsoids);
f1 = figure; hold on;
for i=1:nellipsoids
    c = C{i};  r  = R{i};
    [D(i).X D(i).Y D(i).Z] = ellipsoid(c(1), c(2), c(3), r(1), r(2), r(3), npoints);
    surf(D(i).X, D(i).Y, D(i).Z);
    contour(D(i).X, D(i).Y, D(i).Z, 'LineWidth', 2.5, 'LevelStep', 10)
    colormap copper
end
view([-17, 26])
grid on


