%% This is a simple demo of Matlab's memmapfile class
% Here we memory map the MNIST digit data.
%%

% This file is from pmtk3.googlecode.com

function memoryMapDemo()
if isOctave()
    fprintf('Sorry this demo will only work in Matlab\n');
    return
end
%% load the mnist data
[Xtrain, ytrain, Xtest, ytest] = setupMnist('keepSparse', false);
whos
%% Save the data to a binary file using fwrite
% Here we save the data as int16 and int8, but double works as well if the
% data is not integer typed. Note, however, that double access can be
% considerably slower and take up much more memory.
fname = fullfile(tempdir(), 'mnist.dat');
fid = fopen(fname, 'w');
fwrite(fid, Xtrain, 'int16');
fwrite(fid, ytrain, 'int8');
fwrite(fid, Xtest,  'int16'); % max int16 value is 32767
fwrite(fid, ytest,  'int8');  % max int8 value is 127
fclose(fid);
%% Create the memory map
% For each section of the data, we specify the data type, size, and a name.
mmap = memmapfile(fname, 'Writable', true, 'Format', ...
    {'int16', size(Xtrain), 'Xtrain';
    'int8',  size(ytrain), 'ytrain';
    'int16', size(Xtest),  'Xtest';
    'int8',  size(ytest),  'ytest';
    });
%% random access to data
% Access works just like a regular matlab struct. Our data is stored
% under the 'Data' field.
% The first time a region is requested, access can be slow,
tic
X4000 = mmap.Data.Xtrain(4000, :); % 1x784
y4000 = mmap.Data.ytrain(4000);
toc
%%
% but once the region is cached, access is usually faster.
tic
X4000 = mmap.Data.Xtrain(4000, :);
y4000 = mmap.Data.ytrain(4000);
toc
%% Cast data
% If we want the data returned to be of type double, as required by many
% functions, we can simply cast it.
class(X4000)
X4000 = double(X4000);
class(X4000)
%% Set data
% Since we specified that the map was writable, we can set values too.
mmap.Data.Xtrain(1, 30:35) = 255;
mmap.Data.Xtrain(1, 30:35)
%% Permform usual matlab operations on data
% However, if Xtest is too big to fit all at once, you will have to
% caluculate the mean 'online' and load it in chunks.
xbar = mean(mmap.Data.Xtest, 2);
%% Clean up
clear mmap
delete(fname);
end
