function A = countTransitions(data, nstates)
%% Count the discrete transitions that occur in data
% data is a cell array of cases of potentially different lengths. 
%%

% This file is from pmtk3.googlecode.com


if ~iscell(data)
   if isvector(data)
       data = {data};
   else
       data = mat2cellRows(data);
   end
end

A = zeros(nstates, nstates); 
for i=1:numel(data)
   obs = colvec(data{i}); 
   A = A + accumarray([obs(1:end-1), obs(2:end)], 1, [nstates, nstates]); 
end





end
