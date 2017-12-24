% written by J. Sohl-Dickstein
% based on "The natural gradient by analogy to signal whitening", arxiv
% 2012

function natgradDemo

make_vector_field_plots();
make_convergence_plots();

end

function make_vector_field_plots

[theta1, theta2] = meshgrid( -1:(1/4):1, -1:(1/4):1 );

sf = 3;

theta = [theta1(:)'; theta2(:)'];
X = randn( 2, 10000 );
X = bsxfun( @plus, X, -mean(X,2) );

dL = zeros(size(theta));
for ii = 1:size(theta,2)
    [~, dL(:,ii), G] = L_dL_G( theta( :, ii ), X, sf );
end
dL = -dL;

figure(10); clf;
quiver( theta(1,:), theta(2,:), dL(1,:), dL(2,:) );
xlabel( '\theta_1' );
ylabel( '\theta_2' );
title( 'Steepest descent vectors in original parameter space' );
axis image;

figure(11); clf;
phi = theta;
theta = inv( sqrtm( G ) ) * phi;

dL = zeros(size(theta));
for ii = 1:size(theta,2)
    [~, dL(:,ii), G] = L_dL_G( theta( :, ii ), X, sf );
end
dL = -dL;

dLphi = sqrtm( inv( G ) ) * dL;
quiver( phi(1,:), phi(2,:), dLphi(1,:), dLphi(2,:) );
xlabel( '\phi_1' );
ylabel( '\phi_2' );
title( 'Steepest descent vectors in natural parameter space' );
axis image;

end

function make_convergence_plots
%theta_true = [0;0];
%X = bsxfun( @plus, randn( 2, 10000 ), theta_true );
X = randn( 2, 1000 );
X = bsxfun( @plus, X, -mean(X,2) );

theta_init = [1;-1];
%theta_init = [0;-1];
%theta_init = [0;0];
sf = 3;


%theta_trajectory_steepest = theta_init * ones( 1, 5000000 );
theta_trajectory_steepest = theta_init * ones( 1,  1000000 );
theta_trajectory_natural = theta_trajectory_steepest;
L_trajectory_steepest = zeros( 1, size( theta_trajectory_steepest, 2 )-1 );
L_trajectory_natural = zeros( 1, size( theta_trajectory_steepest, 2 )-1 );

epsilon_steep = 1/sf^2 / 5; % step size
epsilon_nat = epsilon_steep*sf^2;
for ii = 2:size( theta_trajectory_steepest, 2 )
    [L, dL, G] = L_dL_G( theta_trajectory_steepest( :, ii-1 ), X, sf );
    L_trajectory_steepest(ii-1) = L;
    theta_trajectory_steepest( :, ii ) = theta_trajectory_steepest( :, ii-1 ) - epsilon_steep * dL;
    
    [L, dL, G] = L_dL_G( theta_trajectory_natural( :, ii-1 ), X, sf );
    L_trajectory_natural(ii-1) = L;
    theta_trajectory_natural( :, ii ) = theta_trajectory_natural( :, ii-1 ) - epsilon_nat * (G\dL);
end

figure(2); clf;
%plot( [theta_trajectory_steepest(1,:)', theta_trajectory_natural(1,:)'], [theta_trajectory_steepest(2,:)', theta_trajectory_natural(2,:)'], '+', 'x' );
plot( theta_trajectory_steepest(1,:)', theta_trajectory_steepest(2,:)', '+r' ); hold on;
plot( theta_trajectory_natural(1,:)', theta_trajectory_natural(2,:)', 'xb' );
legend( 'Steepest descent', 'Natural gradient descent' );
xlabel( '\theta_1' );
ylabel( '\theta_2' );
title( 'Descent paths for steepest and natural gradient descent' );
axis equal;
figure(3); clf;
%loglog( [L_trajectory_steepest(:), L_trajectory_natural(:)] );
loglog( L_trajectory_steepest(:), '+r' ); hold on;
loglog( L_trajectory_natural(:), 'xb' );
legend( 'Steepest descent', 'Natural gradient descent' );
xlabel( 'Number of update steps' );
ylabel( 'KL divergence' );
title( 'KL divergence vs. update step for steepest and natural gradient descent' );
%keyboard

end

% function [L, dL, G] = L_dL_G( theta, X )
% 
% L = -log(2*pi) - 1/2*(X(1,:) - (10*theta(1) - 10 * theta(2))).^2 - 1/2*(X(2,:) - (1/10 * theta(2))).^2;
% L = -mean(L);
% 
% dlpdtheta = -[10*(X(1,:) - (10*theta(1) - 10 * theta(2)));
%     -10*(X(1,:) - (10*theta(1) - 10 * theta(2))) + 1/10*(X(2,:) - (1/10 * theta(2))) ];
% 
% dL = mean( dlpdtheta, 2 );
% G = dlpdtheta * dlpdtheta' / size( dlpdtheta, 2 );
% 
% end
function [L, dL, G] = L_dL_G( theta, X, sf )

%L = -log(2*pi) - 1/2*(X(1,:) - (10*theta(1) + 1/10 * theta(2))).^2 - 1/2*(X(2,:) - (1/10 * theta(1))).^2;
%L = -mean(L);
KL = 1/2*(X(1,:) - (sf*theta(1) + 1/sf * theta(2))).^2 + 1/2*(X(2,:) - (1/sf * theta(1))).^2 - 1/2*X(1,:).^2 - 1/2*X(2,:).^2;
L = mean(KL);

dlpdtheta = -[sf*(X(1,:) - (sf*theta(1) + 1/sf * theta(2))) + 1/sf*(X(2,:) - (1/sf * theta(1)));
    1/sf*(X(1,:) - (sf*theta(1) + 1/sf * theta(2))) ];
dL = mean( dlpdtheta, 2 );

% %XG = bsxfun( @plus, randn(size(X)), [(10*theta(1) + 1/10 * theta(2)); (1/10 * theta(1))] );
% XG = bsxfun( @plus, X, [(10*theta(1) + 1/10 * theta(2)); (1/10 * theta(1))] );
% dlpdtheta = -[10*(XG(1,:) - (10*theta(1) + 1/10 * theta(2))) + 1/10*(XG(2,:) - (1/10 * theta(1)));
%     1/10*(XG(1,:) - (10*theta(1) + 1/10 * theta(2))) ];
% G = dlpdtheta * dlpdtheta' / size( dlpdtheta, 2 );

G = [ sf^2 + 1/sf^2, 1;
    1, 1/sf^2 ];

end
