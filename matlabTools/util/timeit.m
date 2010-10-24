function t = timeit(f)
% Measure time required to run a function
%   T = TIMEIT(F) measures the time (in seconds) required to run 
%   F, which is a function handle.  
%
%   If nargout(F) is 0, TIMEIT calls F with no output arguments,
%   like this:
%
%       F()
%
%   If nargout(F) is nonzero, TIMEIT calls F with a single output argument,
%   like this:
%
%       OUT = F()
%
%   TIMEIT handles automatically the usual benchmarking
%   procedures of "warming up" F, figuring out how many times to
%   repeat F in a timing loop, etc.  TIMEIT uses a median to form
%   a reasonably robust time estimate.
%
%   Note: The computed time estimate is less accurate when the
%   time required to call F is on the same order as the
%   function-handle calling overhead.  On a 2GHz laptop running
%   R2007b, the function-handle calling overhead is roughly 5e-6
%   seconds. Therefore, it recommended that benchmark problems be
%   constructed so that calling F() requires 1e-4 seconds or
%   longer.
%
%   Examples
%   --------
%   How much time does it take to compute sum(A.' .* B, 1), where
%   A is 12000-by-400 and B is 400-by-12000?
%
%       A = rand(12000, 400);
%       B = rand(400, 12000);
%       f = @() sum(A.' .* B, 1);
%       timeit(f)
%
%   How much time does it take to dilate the text.png image with
%   a 25-by-25 all-ones structuring element?
%
%       bw = imread('text.png');
%       se = strel(ones(25, 25));
%       g = @() imdilate(bw, se);
%       timeit(g)
%
%PMTKurl http://www.mathworks.com/matlabcentral/files/18798/timeit.m
%PMTKauthor Steve Eddins
%PMTKdate February 17, 2008
%   $Revision: 1.4 $  $Date: 2008/02/17 22:06:01 $

% This file is from pmtk3.googlecode.com


t_rough = roughEstimate(f);
% roughEstimate() takes care of warming up f().

% Calculate the number of inner-loop repetitions so that 
% the inner for-loop takes at least about 10ms to execute.
desired_inner_loop_time = 0.01;
num_inner_iterations = max(ceil(desired_inner_loop_time / t_rough), 1);

% Calculate the number of outer-loop repetitions so that the
% outer for-loop takes at least about 1s to execute.  The outer
% loop should execute at least 10 times.
desired_outer_loop_time = 1;
inner_loop_time = num_inner_iterations * t_rough;
min_outer_loop_iterations = 10;
num_outer_iterations = max(ceil(desired_outer_loop_time / inner_loop_time), ...
    min_outer_loop_iterations);

% Get the array of output arguments to be used on the left-hand
% side when calling f.
outputs = outputArray(f);

times = zeros(num_outer_iterations, 1);
for k = 1:num_outer_iterations
    t1 = tic;
    for p = 1:num_inner_iterations
        [outputs{:}] = f(); %#ok<NASGU>
    end
    times(k) = toc(t1);
end

t = median(times) / num_inner_iterations;

end

function t = roughEstimate(f)
%   Return rough estimate of time required for one execution of
%   f().  Basic warmups are done, but no fancy looping, medians,
%   etc.

% Get the array of output arguments to be used on the left-hand
% side when calling f.
outputs = outputArray(f);

% Warm up f().
[outputs{:}] = f(); %#ok<NASGU>
[outputs{:}] = f(); %#ok<NASGU>

% Warm up tic/toc.
t1 = tic();
elapsed = toc(t1); %#ok<NASGU>

counter = 0;
t1 = tic;
while toc(t1) < 0.01
    [outputs{:}] = f(); %#ok<NASGU>
    counter = counter + 1;
end
t = toc(t1) / counter;

end

function outputs = outputArray(f)
%   Return a cell array to be used as the output arguments when
%   calling f.  If nargin(f) is 0, return a 1-by-0 cell array so
%   that f will be called with zero output arguments.  Otherwise,
%   return a 1-by-1 cell array.

num_outputs = ~(nargout(f) == 0);
outputs = cell(1, num_outputs);

end
