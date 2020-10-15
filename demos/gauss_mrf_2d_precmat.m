% Make precision matrix for 2d Gaussian MRF
% Based on p53 of "Introduction to Bayesian Scientific Computing"
% Daniela calvetti and Erkki Somersalo

function L = gauss_mrf_2d_precmat(n)

% http://math.aalto.fi/opetus/inv/TowardsStatIP.pdf
% http://math.tkk.fi/teaching/inv/


% Creating an index matrix to enumerate the pixels
I = reshape([1:n^2],n,n);

% Right neighbors of each pixel
Icurr = I(:,1:n-1);
Ineigh = I(:,2:n);
rows = Icurr(:);
cols = Ineigh(:);
vals = ones(n*(n-1),1);

% Left neighbors of each pixel
Icurr = I(:,2:n);
Ineigh = I(:,1:n-1);
rows = [rows;Icurr(:)];
cols = [cols;Ineigh(:)];
vals = [vals;ones(n*(n-1),1)];

% Upper neighbors of each pixel
Icurr = I(2:n-1,:);
Ineigh = I(1:n-1,:);
rows = [rows;Icurr(:)];
cols = [cols;Ineigh(:)];
vals = [vals;ones(n*(n-1),1)];

% Lower neighbors of each pixel
Icurr = I(1:n-1,:);
Ineigh = I(2:n,:);

rows = [rows;Icurr(:)];
cols = [cols;Ineigh(:)];
vals = [vals;ones(n*(n-1),1)];
A = 1/4*sparse(rows,cols,vals);
L = speye(n^2) - A;

end

