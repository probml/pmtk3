%% Tracking a point in 2D using the LinearDynamicalSystemDist
%#testPMTK
%% Create 'Ground Truth'
stateSize = 4;  % Hidden states are 4D, position and velocity
obsSize   = 2;  % 2D observations
sysMatrix = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
obsMatrix = [1 0 0 0; 0 1 0 0];
sysNoise  = MvnDist(zeros(stateSize,1),0.1*eye(stateSize));
obsNoise  = MvnDist(zeros(stateSize,1),eye(obsSize));
startDist = MvnDist([10;10;1;0],10*eye(stateSize));

groundTruth = LinearDynamicalSystem(...
    'sysMatrix' ,sysMatrix  ,...
    'obsMatrix' ,obsMatrix  ,...
    'sysNoise'  ,sysNoise   ,...
    'obsNoise'  ,obsNoise   ,...
    'startDist' ,startDist  );

%% Sample from 'Ground Truth'
setSeed(8);
nTimeSteps = 15;
[Z,Y] = sample(groundTruth,nTimeSteps);
%% Decode
[ZhatDist,ZZhatDist,loglik] = marginal(groundTruth,'Z','Y',Y);
Zhat    = mean(ZhatDist);
ZhatCov = cov(ZhatDist);
mse_smooth = sqrt(sum(sum((Z([1,2],:) - Zhat([1,2],:)).^2)))  %#ok
%% Plot Results
figure 
hold on; box on; 
set(gca,'XTick',[],'YTick',[]);
plot(Z(1,:), Z(2,:), 'ks-','LineWidth',2);
plot(Y(1,:), Y(2,:), 'g*','LineWidth',2.5);
plot(Zhat(1,:), Zhat(2,:), 'rx:','LineWidth',2.5,'MarkerSize',10);
for t=1:nTimeSteps, gaussPlot2d(Zhat(1:2,t), ZhatCov(1:2, 1:2, t),'b'); end
hold off
legend('true', 'observed', 'smoothed', 3)
