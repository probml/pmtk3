%% Load the tiny images from file
clear all;
saFlag = imread('saFlag.jpg');
saFlagGray = rgb2gray(saFlag); 
figure; imagesc(saFlag); 
figure;  imagesc(saFlagGray); colormap(gray); 

matlabIcon = imread('matlabIcon.jpg');
matlabIconGray = rgb2gray(matlabIcon); 
figure; imagesc(matlabIcon); 
figure; imagesc(matlabIconGray); colormap(gray); 

googleIcon = imread('googleIcon.jpg');
googleIconGray = rgb2gray(googleIcon); 
figure; imagesc(googleIcon); 
figure; imagesc(googleIconGray); colormap(gray); 

brazilFlag = imread('brazilFlag.jpg');
brazilFlagGray = rgb2gray(brazilFlag); 
figure; imagesc(brazilFlag); 
figure; imagesc(brazilFlagGray); colormap(gray); 

canadaFlag = imread('canadaFlag.jpg');
canadaFlagGray = rgb2gray(canadaFlag); 
figure; imagesc(canadaFlag); 
figure; imagesc(canadaFlagGray); colormap(gray); 



save tinyImages