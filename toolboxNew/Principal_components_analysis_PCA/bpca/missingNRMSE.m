function [nrmse, rmse] = missingNRMSE(prob, guess, answer)
%[nrmse, rmse] = missingNRMSE(prob, guess, answer)
% Calculate NRMSE (normalized root mean squared error) for the
%  missing value estimation problem.
% prob: Definition of the problem
%     an expression matrix with some entries are missing (denoted
%     by 999.0)
% guess: The guessed answer, as a fulfilled expression matrix.
% answer: True answer, as a complete matrix.

missidx = find( prob>990 );
nrmse = sqrt( mean( (guess(missidx)-answer(missidx)).^2 ) ) ...
	/ std( answer(missidx) );
rmse =  sqrt( mean( (guess(missidx)-answer(missidx)).^2 ) );

end