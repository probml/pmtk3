function f = fnameOnly(fullPath)
%% Return the filename given its full path
% e.g. fnameOnly('C:\foo\bar\test.m') yields 'test'

if iscell(fullPath)
    f = cellfuncell(@fnameOnly, fullPath); 
    return;
end

f = argout(2, @fileparts, fullPath); 
end