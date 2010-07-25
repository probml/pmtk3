function C = removeDuplicates(C)
%% Like built in unique function but does alter the order by sorting
% Keeps only the first occurence of each unique element. 
%%
C(setdiffPMTK(1:numel(C), argout(2, @unique, C, 'first'))) = [];
end
