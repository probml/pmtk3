function biplotPmtk(C, varargin)
%% Replacement for the stats toolbox biplot function

% This file is from pmtk3.googlecode.com


[S, labels, pos] = process_options(varargin, ...
    'scores'    , []    , ...
    'varlabels' , []    , ...
    'positive'  , false );

[n, d] = size(C);
is3D   = (d == 3);
ns     = size(S, 1);
maxind = maxidx(abs(C), [], 1);
csgn   = sign(C(maxind + (0:n:(d-1)*n)));
C      = C .* repmat(csgn, n, 1);
X      = [zeros(n, 1) C(:, 1) ]';
Y      = [zeros(n, 1) C(:, 2) ]';
lnprop = {'linewidth', 2};
if is3D
    Z = [zeros(n, 1) C(:, 3)]';
    line(X(1:2, :), Y(1:2, :), Z(1:2, :), lnprop{:});
else
    line(X(1:2, :), Y(1:2, :), lnprop{:});
end
if ~isempty(labels)
    dx = .02*diff(get(gca, 'xlim'));
    dy = .02*diff(get(gca, 'ylim'));
    if is3D
        dz = .02*diff(get(gca, 'zlim'));
    end
    txtprop = {'fontsize', 7, 'fontweight', 'bold'};
    if is3D, text(C(:, 1)+dx, C(:, 2)+dy, C(:, 3)+dz, labels, txtprop{:}); 
    else     text(C(:, 1)+dx, C(:, 2)+dy, labels, txtprop{:}); 
    end 
end
view(d)
if is3D
    grid on;
end
high = 1.1*max(abs(C(:)));
low = -high * ~pos;
if is3D
    line([low high NaN 0 0 NaN 0 0], ...
         [0 0 NaN low high NaN 0 0], ...
         [0 0 NaN 0 0 NaN low high], ...
        'color', 'black');
else
    line([low high NaN 0 0], ...
        [0 0 NaN low high], ...
        'color', 'black');
end
xlabel('Component 1');
ylabel('Component 2');
if is3D,  zlabel('Component 3'); end
axis tight
if ~isempty(S)
    maxlen = sqrt(max(sum(C.^2,2)));
    S      = maxlen.*(S ./ max(abs(S(:)))) .* repmat(csgn, ns, 1);
    xx     = S(:, 1)';
    yy     = S(:, 2)';
    dataprop = {'or', 'markersize', 4};
    if is3D
        zz = S(:,3)';
        hold on; 
        h = plot3(xx, yy, zz, dataprop{:});
    else
        hold on; 
        h = plot(xx, yy, dataprop{:}); 
    end
    uistack(h, 'bottom');
end
if pos
    a = axis;
    a(1:2:end) = 0;
    axis(a);
end
end
