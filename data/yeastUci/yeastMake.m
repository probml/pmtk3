%http://www.mathworks.com/access/helpdesk/help/toolbox/bioinfo/index.html?/access/helpdesk/help/toolbox/bioinfo/ug/a1060813239b1.html

load yeastdata.mat

%%%%%%%%%%%%% filtering
emptySpots = strcmp('EMPTY',genes);
yeastvalues(emptySpots,:) = [];
genes(emptySpots) = [];

nanIndices = any(isnan(yeastvalues),2);
yeastvalues(nanIndices,:) = [];
genes(nanIndices) = [];

mask = genevarfilter(yeastvalues);
% Use the mask as an index into the values to remove the 
% filtered genes.
yeastvalues = yeastvalues(mask,:);
genes = genes(mask);

[mask, yeastvalues, genes] = genelowvalfilter(yeastvalues,genes,'absval',log2(4));
[mask, yeastvalues, genes] = geneentropyfilter(yeastvalues,genes,'prctile',15);

numel(genes) % 310

X = yeastvalues;
save('C:\kmurphy\PML\Data\Data\yeastData310.mat', 'X', 'genes', 'times');

