function T = unSandwich(str, leftMarker, rightMarker)
%% Like tokenize, but extracts text between 'sandwiching' markers
% 
%% Output
% meat     - a (possibly empty) cell array of the unsandwiched tokens
%% Example
%
% meat = unSandwich('please see <mywebsite.html> or <wikipedia.org> for details.', '<', '>')
%
% meat = {'mywebsite.html', 'wikipedia.org'}
%%

% This file is from pmtk3.googlecode.com

toks = tokenize(str, [leftMarker, rightMarker]); 
if numel(toks) < 2
    T = {};
else
    remaining = str(find(str==rightMarker, 1, 'first')+1:end); 
    T = [toks(2), unSandwich(remaining, leftMarker, rightMarker)] ;
end
end
