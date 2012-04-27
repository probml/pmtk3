% Demo of the TrueSkill model
%PMTKauthor Carl Rasmussen and  Joaquin Quinonero-Candela,
%PMTKurl http://mlg.eng.cam.ac.uk/teaching/4f13/1112
%PMTKmodified Kevin Murphy

function trueskillDemo()

setSeed(0);

% Let us assume the following partial order on players
% where higher up is better
%     1
%    /  \
%    2   3
%     \/
%     4
%    /  \
%   5    6
% We will sample data from this graph, where we let each player
% beat its children K times

Nplayers = 6;
G = zeros(Nplayers, Nplayers);
G(1,[2 3]) = 1;
G(2,4) = 1;
G(3,4) = 1;
G(4, [5 6]) = 1;

%g = drawNetwork('-adjMat', G);

data = zeros(0,2);
game = 1;
for i=1:Nplayers
  ch = children(G,i);
  for j=ch(:)'
    % Sample the number of games between this pair
    K = sampleDiscrete([0.3 0.1 0.1 0.1 0.4], 1);
    for k=1:K
      data(game, :) = [i j];
      game = game + 1;
    end
  end
end
data
size(data)
Ngames = zeros(1,Nplayers);
for i=1:Nplayers
  Ngames(i) = sum(data(:,1)==i) + sum(data(:,2)==i);
end

[Ms, Ps] = trueskillEP(Nplayers, data);
[junk, order] = sort(Ms, 'descend');

sigmas = sqrt(1./Ps);
for i=1:Nplayers
  j = order(i);
  fprintf('rank %d, player %d, num games %d, skill = %5.3f (std %5.3f)\n', ...
    i, j, Ngames(j), Ms(j), sigmas(j));
end

figure;
errorbar(1:Nplayers, Ms, sigmas, 'linewidth', 3);
printPmtkFigure('trueskillDemo')



end

function [Ms, Ps] = trueskillEP(M, G)
% Input:
% M = number of players
% G(i,1) = id of winner for game i
% G(i,2) = id of loser for hgame i
%
% Output:
% Ms(p) = mean of skill for player p
% Ps(p) = precision of skill for player p

N = size(G,1);            % number of games

psi = inline('normpdf(x)./normcdf(x)');
lambda = inline('(normpdf(x)./normcdf(x)).*( (normpdf(x)./normcdf(x)) + x)');

pv = 0.5;            % prior skill variance (prior mean is always 0)

% initialize matrices of skill marginals - means and variances
Ms = nan(M,1); 
Ps = nan(M,1);

% initialize matrices of game to skill messages - means and precisions
Mgs = zeros(N,2); 
Pgs = zeros(N,2);

% allocate matrices of skill to game messages - means and precisions
Msg = nan(N,2); 
Psg = nan(N,2);

for iter=1:5
  % (1) compute marginal skills 
  for p=1:M
    % compute this first because it is needed for the mean update
    Ps(p) = 1/pv + sum(Pgs(G==p)); 
    Ms(p) = sum(Pgs(G==p).*Mgs(G==p))./Ps(p);
  end

  % (2) compute skill to game messages
  % compute this first because it is needed for the mean update
  Psg = Ps(G) - Pgs;
  %Msg = (Ps(G).*Ms(G) - Pgs.*Mgs)./Ps(G); 
  Msg = (Ps(G).*Ms(G) - Pgs.*Mgs)./Psg(G); % KPM 
     
  % (3) compute game to performance messages
  vgt = 1 + sum(1./Psg, 2);
  mgt = Msg(:,1) - Msg(:,2); % player 1 always wins the way we store data
   
  % (4) approximate the marginal on performance differences
  Mt = mgt + sqrt(vgt).*psi(mgt./sqrt(vgt));
  Pt = 1./( vgt.*( 1-lambda(mgt./sqrt(vgt)) ) );
    
  % (5) compute performance to game messages
  ptg = Pt - 1./vgt;
  mtg = (Mt.*Pt - mgt./vgt)./ptg;   
    
  % (6) compute game to skills messages
  Pgs = 1./(1 + repmat(1./ptg,1,2) + 1./Psg(:,[2 1]));
  Mgs = [mtg, -mtg] + Msg(:,[2 1]);
end

end

