function cfiles = cfilelist(directory)
% Return a list of all .c and .cpp files in the specified directory structure
if nargin == 0, directory = pwd(); end
cfiles = filelist(directory, {'*.c', '*.cpp'}); 
end