function out = prepareArgs(args)
% Convert a struct into a name/value cell array for use by process_options
%
% Prepare varargin args for process_options by converting a struct in args{1}
% into a name/value pair cell array. If args{1} is not a struct, args
% is left unchanged.
% Example:
% opts.maxIter = 100;
% opts.verbose = true;
% foo(opts)
% 
% This is equivalent to calling 
% foo('maxiter', 100, 'verbose', true)

% This file is from pmtk3.googlecode.com


if isstruct(args)
    out = interweave(fieldnames(args), struct2cell(args));
elseif ~isempty(args) && isstruct(args{1})
    out = interweave(fieldnames(args{1}), struct2cell(args{1}));
else
    out = args;
end




end
