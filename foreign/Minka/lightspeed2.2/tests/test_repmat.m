if 0
  % functionality test
  repmat([1 2; 3 4],2,4,2,2)
  repmat([1 2; 3 4],[2 4 2 2])
  repmat([1 2; 3 4],2)
  repmat(j,3,2)
  repmat('hello',3,2)
  repmat({7},3,2)
  repmat(sparse(7),3,2)
end

x = rand(300,1);
x = rand(10,1);
% run it once to load the definition
repmat(1,1,1);
niter = 100000/prod(size(x));
n = 100;
fprintf('repmat(x,1,n)\n');
tic; for i = 1:niter xrepmat(x,1,n); end; t0=toc; 
fprintf('old repmat: %g\n',t0); 
tic; for i = 1:niter repmat(x,1,n); end; t=toc; 
fprintf('new repmat: %g (%g times faster)\n',t,t0/t);

if 0
  % repmat is faster than ones
  tic; for i = 1:niter ones(300,1000); end; toc
  tic; for i = 1:niter xrepmat(ones(300,1),1,1000); end; toc
  tic; for i = 1:niter repmat(1,300,1000); end; toc
end

if 0
  % zeros is faster than repmat (as expected)
  tic; for i = 1:niter zeros(300,1000); end; toc
  tic; for i = 1:niter repmat(zeros(300,1),1,1000); end; toc
  tic; for i = 1:niter xrepmat(0,300,1000); end; toc
end

if 0
  fprintf('new repmat:');
  tic; for i = 1:niter repmat(x',1000,1); end; toc
  fprintf('old repmat:');
  tic; for i = 1:niter xrepmat(x',1000,1); end; toc
end

if 0
  fprintf('new repmat:');
  tic; for i = 1:niter repmat(x,1000,1); end; toc
  fprintf('old repmat:');
  tic; for i = 1:niter xrepmat(x,1000,1); end; toc
end
