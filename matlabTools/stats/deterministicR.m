function outIndex = deterministicR(inIndex,q);
% PURPOSE : Performs the resampling stage of the SIR
%           in order(number of samples) steps. It uses Kitagawa's
%           deterministic resampling algorithm.
% INPUTS  : - inIndex = Input particle indices.
%           - q = Normalised importance ratios.
% OUTPUTS : - outIndex = Resampled indices.
% AUTHORS  : Arnaud Doucet and Nando de Freitas - Thanks for the acknowledgement.
% DATE     : 08-09-98

if nargin < 2, error('Not enough input arguments.'); end

[S,arb] = size(q);  % S = Number of particles.

% RESIDUAL RESAMPLING:
% ====================

N_babies= zeros(1,S);
u=zeros(1,S);

% generate the cumulative distribution
cumDist = cumsum(q');
aux=rand(1);
u=aux:1:(S-1+aux);
u=u./S;
j=1;
for i=1:S
   while (u(1,i)>cumDist(1,j))
      j=j+1;
   end
   N_babies(1,j)=N_babies(1,j)+1;
end

% COPY RESAMPLED TRAJECTORIES:  
% ============================
index=1;
for i=1:S
  if (N_babies(1,i)>0)
    for j=index:index+N_babies(1,i)-1
      outIndex(j) = inIndex(i);
    end;
  end;   
  index= index+N_babies(1,i);   
end












