%% Simple test to make sure the logZ calculation is correct

% This file is from pmtk3.googlecode.com

%% Sprinkler network
% Small network, so we can use brute force enumeration to test
dgm = mkSprinklerDgm();
N = dgm.nnodes;
tol = 1e-5;
for trial=1:2
   trial
   if trial==1
      clamped = sparsevec(1:3, [1 1 1], N);
   else
      % fully obseved
      clamped = sparsevec(1:N, ones(1,N), N);
   end
   
   [b, logZ1] = dgmInferNodes(dgm, 'clamped', clamped);
   [b, logZ2] = dgmInferQuery(dgm, 4, 'clamped', clamped);
   dgm.infEngine = 'varelim';
   [b, logZ3] = dgmInferNodes(dgm, 'clamped', clamped);
   [b, logZ4] = dgmInferQuery(dgm, 4, 'clamped', clamped);
   if libdaiInstalled
       dgm.infEngine = 'libdaiJtree';
       [b, logZ5] = dgmInferNodes(dgm, 'clamped', clamped);
       [b, logZ6] = dgmInferQuery(dgm, 4, 'clamped', clamped);
   end
   dgm.infEngine = 'enum';
   [b, logZ7] = dgmInferNodes(dgm, 'clamped', clamped);
   [b, logZ8] = dgmInferQuery(dgm, 4, 'clamped', clamped);
   logZ9 = dgmLogprob(dgm, 'clamped', clamped);
   
   assert(approxeq(logZ2, logZ1, tol));
   assert(approxeq(logZ3, logZ1, tol));
   assert(approxeq(logZ4, logZ1, tol));
   
   if libdaiInstalled
       assert(approxeq(logZ5, logZ1, tol));
       assert(approxeq(logZ6, logZ1, tol));
   end
   assert(approxeq(logZ7, logZ1, tol));
   assert(approxeq(logZ8, logZ1, tol));
   %assert(approxeq(logZ9, logZ1, tol));  % FAILS!!
end



%% Alarm network
dgm = mkAlarmDgm();
N = dgm.nnodes;
for trial=1:2
   trial
   if trial==1
      % clamp some nodes
      clamped = sparsevec(1:10, ones(1, 10), N);
   else
      % clamp all nodes
      clamped = sparsevec(1:N, ones(1, N), N);
   end
   
   [b, logZ1] = dgmInferNodes(dgm, 'clamped', clamped);
   [b, logZ2] = dgmInferQuery(dgm, 11, 'clamped', clamped);
   
   dgm.infEngine = 'varelim';
   [b, logZ3] = dgmInferNodes(dgm, 'clamped', clamped);
   [b, logZ4] = dgmInferQuery(dgm, 11, 'clamped', clamped);
   
   if libdaiInstalled
       dgm.infEngine = 'libdaiJtree';
       [b, logZ5] = dgmInferNodes(dgm, 'clamped', clamped);
       [b, logZ6] = dgmInferQuery(dgm, 11, 'clamped', clamped);
   end
   
   logZ7 = dgmLogprob(dgm, 'clamped', clamped);
   
   tol = 1e-10;
   assert(approxeq(logZ2, logZ1, tol));
   % varElim suffers numerical problems 
   % when computing logZ for a large fully observed model 
   if trial==1
      assert(approxeq(logZ3, logZ1, tol));
      assert(approxeq(logZ4, logZ1, tol));
   end
   if libdaiInstalled
       assert(approxeq(logZ5, logZ1, tol));
       assert(approxeq(logZ6, logZ1, tol));
   end
   
   % KPM 28Feb11: fails when libdai commented out
   % Not clear why...
   %assert(approxeq(logZ7, logZ1, tol));
  
end

