function net = convertoldnet(net)
%CONVERTOLDNET Convert pre-2.3 release MLP and MDN nets to new format
%
%	Description
%	NET = CONVERTOLDNET(NET) takes a network NET and, if appropriate,
%	converts it from pre-2.3 to the current format.  The difference is
%	simply  that in MLPs and the MLP sub-net of MDNs the field ACTFN has
%	been  renamed OUTFN to make it consistent with GLM and RBF networks.
%	If the network is not old-format or an MLP or MDN it is left
%	unchanged.
%
%	See also
%	MLP, MDN
%

%	Copyright (c) Ian T Nabney (1996-2001)

switch net.type
    case 'mlp'
	if (isfield(net, 'actfn'))
	    net.outfn = net.actfn;
	    net = rmfield(net, 'actfn');
	end
    case 'mdn'
	net.mlp = convertoldnet(net.mlp);
end
