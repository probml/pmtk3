function enum = enumerate(strings)
% Returns a struct, whose fields are the input strings and whose
% correspoding values are the numbers 1:numel(strings) so that
% enum.(strings{i}) = i for all i in 1:numel(strings). If any string is not
% a valid field name, it is made valid using genvarname(), therefore it is
% good practice to index into enum with enum.(genvarname(name)).
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

    enum = createStruct(cellfuncell(@genvarname,strings),num2cell(1:numel(strings)));
end