%% Plot a spectogram and its MFCC representation
% Data source: Tommi Jaakkola
load data45;
figure; specgram(signal1); title('spectogram of "four"');
printPmtkFigure('speechFourSpectogram'); 
figure; imagesc(train4{1}); title('mfcc of "four"');
printPmtkFigures('speechFourMFCC2'); 