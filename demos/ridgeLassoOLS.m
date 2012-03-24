function ridgeLassoOLS

X1 = [-2 2]; 
Y1 = [-1 1]; 
plot(X1, Y1, '-r', 'linewidth', 6);
hold on; 
X2 = X1; 
Y2 = [-0.5 0.5];
plot(X2, Y2, ':g', 'linewidth', 6); 

X3a = [-2 -1]; 
Y3a = [-0.5 0]; 

X3b = [-1 1]; 
Y3b = [0 0]; 

X3c = [1 2]; 
Y3c = [0 0.5]; 

plot(X3a, Y3a, '--k', 'linewidth', 6); 

legend('1', '2', '3', 'location', 'northwest'); 

plot(X3b, Y3b, '--k', 'linewidth', 6); 
plot(X3c, Y3c, '--k', 'linewidth', 6); 


axis([-2 2 -1 1]); 

xlabel('c_k', 'fontsize', 36); 
ylabel('w_k', 'fontsize', 36); 
set(gca, 'fontsize', 24); 
grid on; 

printPmtkFigure ridgeLassoOLS





end