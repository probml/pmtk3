function BPCA_plotM(M)

% BPCA_plotM(M)
% plot profile of BPCA model M

subplot(2,1,1)
plot(M.alpha)
ylabel('alpha')
xlabel('factor index')

subplot(2,1,2)
w2 = diag(M.W'*M.W);
plot( log10(w2) );
hold on
plot( [1 length(w2)], -[1 1]*log10(M.tau), 'r-')
ylabel('log_{10} eigen value')
xlabel('factor index')
ax = axis;
axis( [ax(1:2) -5 5] );
text( 0, -2-log10(M.tau),['tau=' num2str(M.tau)])
end