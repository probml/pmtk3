%% Make the lung cancer dgm
%
%%
function dgm = mkLungCancerDgm(varargin)
%     S
%    / \
%   v  v
%  CB  LC
%    \/   \
%    v     v
%   SOB    X
%%
S = 1; CB = 2; LC = 3; SOB = 4; X = 5;
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

dgm = dgmCreate(G, CPDs, varargin{:}); 


end