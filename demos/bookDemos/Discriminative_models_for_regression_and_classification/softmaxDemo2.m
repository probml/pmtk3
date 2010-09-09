%% Plot the softmax function as a histogram for various temperatures 
%
%%

% This file is from pmtk3.googlecode.com

T = [100 10 1 0.1];
eta = [3 0 1];
figure();
nr = 1; 
nc = numel(T);
for i=1:numel(T)
    subplot(nr, nc, i)
    bar(softmaxPmtk(eta./T(i))); 
    title(sprintf('T = %g', T(i)));
end
printPmtkFigure('softmaxDemo2'); 
