function d = containingDirectory(f)
%% Return the containing directory of the file
%
%% Example 
%
% d = containingDirectory('C:\foo\bar\test.txt')
% d = 
% 'bar'
%%
d = argout(2, @fileparts, (fileparts(f)));

end