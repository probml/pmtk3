nCases = 100; nReplicates = 20; lambda = 100; frac = 50;
sizeMat = zeros(nCases, 2);
sizeMat = poissrnd(lambda, [nCases, 2]);
nElements = prod(sizeMat,2);
idx = cell(nCases, 1);
for i=1:nCases
  idx{i} = unidrnd(nElements(i), floor(nElements(i) / frac));
end

tic;
for j=1:nReplicates
fprintf('%d, ', j)
  for i=1:nCases
    ind2subv(sizeMat(i,:), idx{i});
  end
end
t = toc;
fprintf('ind2subv took %g seconds\n', t);

tic;
for j=1:nReplicates
fprintf('%d, ', j)
  for i=1:nCases
    ind2subvBsxfun(sizeMat(i,:), idx{i});
  end
end
t = toc;
fprintf('ind2subv with bsxfun took %g seconds\n', t);