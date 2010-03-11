function out = prepareArgs(args)
% Prepare varargin args for process_options by converting a struct in args{1}
% into a name/value pair cell array. If args{1} is not a strucct, args
% is left unchanged.

if isstruct(args)
    out = interweave(fieldnames(args), struct2cell(args));
elseif ~isempty(args) && isstruct(args{1})
    out = interweave(fieldnames(args{1}), struct2cell(args{1}));
else
    out = args;
end




end