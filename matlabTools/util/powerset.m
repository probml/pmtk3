function p = powerset(set)
% Return the power set of a set of integers
% e.g. powerset(1:3) = {[],1,2,3,[1,2],[1,3],[2,3],[1,2,3]}

% This file is from pmtk3.googlecode.com

p = sortfun(@(x)numel(x), cellfuncell(@(x)set(x),...
    num2cell(dec2bin(2^numel(set)-1:-1:0) == '1', 2)));
end


