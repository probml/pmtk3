function ndx = greedySpan(set, subsets)
%% Greedily build up a set from a minimal number of disjoint subsets
% Example: greedySpan(1:10, {[2 3], [2 5 7], [1 4] [1 3 4 6 10], [8], [9]})
% will return indices [2, 4, 5, 6] in the subsets cell array
%
% If no solution can be found, [] is returned.
%%

% This file is from pmtk3.googlecode.com

sizes = cellfun(@numel, subsets);

ndxBit = false(1, numel(subsets));
ndx = [];
done = false;
while not(done)
    if isempty(subsets), return; end
    candidates = find(cellfun(@(ss)issubset(ss, set), subsets));
    if isempty(candidates), return; end
    largest = candidates(maxidx(sizes(candidates)));
    ndxBit(largest) = true;
    set = setdiff(set, subsets{largest}); 
    subsets{largest} = [];
    sizes(largest) = 0; 
    if all(~sizes), return; end
    done = isempty(set); 
    
end
ndx = find(ndxBit);


end
