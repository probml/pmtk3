function enum = enumerate(strings)
% Create an inverted map from strings to their index values in a list
%
% If any string is not a valid field name, it is made valid using
% genvarname(), therefore it is good practice to index into enum with
% enum.(genvarname(name)).
%
% EXAMPLE:
%
% enum = enumerate({'alpha','beta','gamma','delta','epsilon','zeta','eta'})
% enum =
%       alpha: 1
%        beta: 2
%       gamma: 3
%       delta: 4
%     epsilon: 5
%        zeta: 6
%         eta: 7

% This file is from pmtk3.googlecode.com


enum = createStruct(cellfuncell(@genvarname, strings), num2cell(1:numel(strings)));
end
