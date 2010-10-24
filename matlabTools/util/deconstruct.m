function varargout = deconstruct(S)
% Deconstruct a structure from the output arguments only
% See also, structure().
%% Example
% mu = zeros(1, 10);
% Sigma = randpd(10);
% pi = normalize(ones(1, 10));
% model = structure(mu, Sigma, pi);
%
% [mu, Sigma, pi] = deconstruct(model); % cannot be called from the command line.
%
% *** warning this function is not efficient ***

% This file is from pmtk3.googlecode.com

stack = dbstack('-completenames');
if numel(stack) < 2
    error('This function cannot be called from the command prompt');
end
linenum = stack(2).line;
fid = fopen(stack(2).file, 'r');
for i=1:linenum-1
    fgetl(fid);
end
line = fgetl(fid);
fclose(fid);
toks = tokenize(line, '=');
outputnames = tokenize(toks{1}, ',[] ');
for i=1:numel(outputnames)
    varargout{i} = S.(outputnames{i});
end

end
