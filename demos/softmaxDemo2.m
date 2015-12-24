%% Plot the softmax function as a histogram for various temperatures 
%
%%

% This file is from pmtk3.googlecode.com

T = [100 5 1];
eta = [3 0 1];
figure();
nr = 1; 
nc = numel(T);
for i=1:numel(T)
    %subplot(nr, nc, i)
    figure;
    bar(softmaxPmtk(eta./T(i))); 
    title(sprintf('T = %g', T(i)));
    set(gca,'ylim',[0 1]);
    printPmtkFigure(sprintf('softmax_temp%d', T(i)));
end
%printPmtkFigure('softmaxDemo2'); 
