
% For BXPCA only, produce the data for boxplots of the performance of the
% data over various datasets and for different K.

% Create the 20 Datasets that will be used for testing

% modGenData = load('toydata1');
% X = modGenData.data;
[numObs, numFeatures] = size(X);
% Select which elements should have missing entries
probRowSel = 0.1;
for i = 1:20
    idx = logical(binornd(1,probRowSel,numObs,numFeatures));
    numMissing = sum(sum(idx)); percMissing = numMissing / numel(X)
    % Set the elements to correct indicator vals
    trainData = X; testData = X;
    trainData(idx) = -1; % Set all test Data to -1
    testData(~idx) = -1; % set all data used in training to -1.
    fname = sprintf('spectData%d',i);
    save(fname,'trainData','testData', 'X', 'probRowSel');
end;