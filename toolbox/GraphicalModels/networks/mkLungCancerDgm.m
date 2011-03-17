%% Make the lung cancer dgm
%
%%

% This file is from pmtk3.googlecode.com

function dgm = mkLungCancerDgm(toporder)
%     S
%    / \
%   v  v
%  CB  LC
%    \/   \
%    v     v
%   SOB    X

if nargin < 1, toporder = true; end

if toporder
  S = 1; CB = 2; LC = 3; SOB = 4; X = 5;
  names = {'S','CB','LC','SOB','X'};
else
  % pick a random node ordering, as a test
  S = 5; CB = 4; LC = 2; SOB = 1; X = 3;
  names  = cell(1, 5);
  names{S} = 'S'; names{CB} = 'CB'; names{LC} = 'LC';
  names{SOB} = 'SOB'; names{X} = 'X';
end

G = zeros(5, 5);
G(S,[CB LC]) = 1;
G([CB LC], SOB) = 1;
G(LC, X) = 1;



%% Make CPDs
% Specify the conditional probability tables as cell arrays
% The left-most index toggles fastest, so entries are stored in this order:
% (1,1,1), (2,1,1), (1,2,1), (2,2,1), etc.

CPDs{S}   = tabularCpdCreate(reshape([0.8 0.2], 2, 1));
CPDs{CB}  = tabularCpdCreate(reshape([0.95 0.75  0.05 0.25], 2, 2));
CPDs{LC}  = tabularCpdCreate(reshape([0.99995 0.997 0.00005 0.003], 2, 2));
CPDs{SOB} = tabularCpdCreate(reshape([0.95 0.5 0.5 0.25  0.05 0.5 0.5 0.75], 2, 2, 2));
CPDs{X}   = tabularCpdCreate(reshape([0.98 0.4 0.02 0.6], 2, 2)); 

dgm = dgmCreate(G, CPDs, 'nodenames', names); 


end
