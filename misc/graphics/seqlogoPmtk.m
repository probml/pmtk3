function varargout = seqlogoPmtk(p, ssCorr)
%% A replacement function for the bioinformatics seqlogo function
% Unlike seqlogo, this only support nucleotides, i.e. ACGT, not amino acids
%% Input
%
% p        - an nsequences-by-npositions character array of with chars 
%            A,C,T,G, or a profile matrix of the same size.
% 
% ssCorr   - if true, (default), the small sample size correction is 
%            applied. This setting is ignormed, (turned off) if p is a 
%            numeric profile matrix.
%            (see the bioinformatics seqlogo function for details)
%% Output, (optional)
%
% W        - an nsequenes-by-npositions conservation weight matrix as
%            produced by max(conservationWeights(p, ssCorr), 0); 
% 
% h        - bar series handle
%
%% See also
% conservationWeights
%% if no input, display a test matrix
if nargin == 0; 
    p = ['cgatacggggtcgaa'
         'caatccgagatcgca'
         'caatccgtgttggga'
         'caatcggcatgcggg'
         'cgagccgcgtacgaa'
         'catacggagcacgaa'
         'taatccgggcatgta'
         'cgagccgagtacaga'
         'ccatccgcgtaagca'
         'ggatacgagatgaca'
        ];
end
if nargin < 2, ssCorr = true; end
%%
% weights can be negative due to small sample size correction
W = max(conservationWeights(p, ssCorr), 0); 
[Wsorted, perm] = sort(W, 1);
%%
fig      = figure('color', 'white');
mainax   = axes();
%% Use bar to calculate vertices
barWidth = 0.95; 
h = bar(Wsorted', barWidth    , 'stacked' , ...
                  'edgecolor' , 'none'    , ...
                  'facecolor' , 'none'    );
%%              
set(mainax, 'ylim', [0, 2]); % log2(4)
rows    = get(h, 'children');
L       = load('seqlogoLetters.mat');
letters = {L.A, L.C, L.G, L.T};
thresh  = 0.005;    % letters with heights less than this are not printed
for i=1:numel(rows) % rows(1) is the lowest row in the figure
    row = rows{i};
    X   = get(row, 'xdata');
    Y   = get(row, 'ydata'); 
    for j=1:numel(letters)
        pos = find(perm(i, :) == j);
        for k=1:numel(pos)
            letterpos = imagePosition(mainax, X(:, pos(k)), Y(:, pos(k)));
            height = letterpos(4); 
            if height < thresh
                continue;
            end
            ax = axes('parent', fig, 'position', letterpos);
            image(letters{j});
            axis(ax, 'off');
        end
    end
end
set(mainax, 'ytick'      , 0:2           , ...
            'xtick'      , 1:size(W, 2)  , ...
            'fontweight' , 'bold'        , ...
            'box'        , 'off'         , ...
            'ticklength' , [0 0]         , ...
            'linewidth'  , 2             );             
xlabel(mainax, 'Sequence Position', 'fontweight', 'bold');
ylabel(mainax, 'Bits', 'fontweight', 'bold');
set(fig, 'currentaxes', mainax); % so that gca returns right axes
%%
varargout = {}; 
if nargout > 0
   varargout = {W, h};  
end
end

function p = imagePosition(ax, Xvert, Yvert)
% Return the axis relative location for the letter, given the vertices
% calcualted by bar().  

gutter = 0.01; % don't rest letters exactly on x-axis: messes up printing
left   = rel2absX(Xvert(1), ax);
right  = rel2absX(Xvert(3), ax);
width  = right - left;
bottom = rel2absY(Yvert(1) + gutter, ax);
top    = rel2absY(Yvert(3) + gutter, ax);
height = top - bottom;
p      = [left, bottom, width, height];
end