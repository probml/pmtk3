function [centers,mincenter,mindist,q2,quality] = kmeansElkan(data,initcenters,method)
% Kmeans clustering using Elkan's triangle inequality speedup
% output: final centers
% input: data points and initial centers
% if initcenters is a number k, create k centers and start with these
% otherwise, use centers given as input
% method = 0: unoptimized, using n by k matrix of distances O(nk) space
%          1: vectorized, using only O(n+k) space
%          2: like 1, in addition using distance inequalities (default)

%PMTKauthor Charles Elkan

% "Using the triangle inequality to accelerate k-means",
% ICML 2003

if nargin < 3 method = 2; end
[n,dim] = size(data);

if max(size(initcenters)) == 1
    k = initcenters;
    [centers, mincenter, mindist, lower, computed] = anchors(mean(data),k,data);
    total = computed;
    skipestep = 1;
else 
    centers = initcenters;
    mincenter = zeros(n,1);
    total = 0;
    skipestep = 0;
    [k,dim2] = size(centers);    
    if dim ~= dim2 error('dim(data) ~= dim(centers)'); end;
end

nchanged = n;
iteration = 0;
oldmincenter = zeros(n,1);

while nchanged > 0
    % do one E step, then one M step
    computed = 0;
    
    if method == 0 & ~skipestep
        for i = 1:n
            for j = 1:k
                distmat(i,j) = calcdist(data(i,:),centers(j,:));
            end
        end
        [mindist,mincenter] = min(distmat,[],2);
        computed = k*n;

    elseif (method == 1 | (method == 2 & iteration == 0)) & ~skipestep
        mindist = Inf*ones(n,1);
        lower = zeros(n,k);
        for j = 1:k
           jdist = calcdist(data,centers(j,:));
           lower(:,j) = jdist;
           track = find(jdist < mindist);
           mindist(track) = jdist(track);
           mincenter(track) = j;
        end
        computed = k*n;

    elseif method == 2 & ~skipestep 
        computed = 0;

% for each center, nndist is half the distance to the nearest center
% if d(x,center) < nndist then x cannot belong to any other center
% mindist is an upper bound on the distance of each point to its nearest center

        nndist = min(centdist,[],2);
% the following usually is not faster        
%        ldist = min(lower,[],2);
%        mobile = find(mindist > max(nndist(mincenter),ldist));
        mobile = find(mindist > nndist(mincenter));
        
% recompute distances for point i and center j 
%       only if j can possibly be the new nearest center
% for speed, the first check has been optimized by modifying centdist
% swapping the order of the checks is slower for data with natural clusters

        mdm = mindist(mobile);
        mcm = mincenter(mobile);
 
        for j = 1:k
% the following is incorrect: for j = unique(mcm)'
            track = find(mdm > centdist(mcm,j));
            if isempty(track) continue; end
            alt = find(mdm(track) > lower(mobile(track),j));          
            if isempty(alt) continue; end
            track1 = mobile(track(alt));
                    
% calculate exact distances to the mincenter
% recalculate separately for each jj to avoid copying too much of data
% redo may be empty, but we don't need to check this
            redo = find(~recalculated(track1));
            redo = track1(redo);
            c = mincenter(redo);
            computed = computed + size(redo,1);
            for jj = unique(c)'
                rp = redo(find(c == jj));
                udist = calcdist(data(rp,:),centers(jj,:));
                lower(rp,jj) = udist;
                mindist(rp) = udist;
            end
            recalculated(redo) = 1;
            
            track2 = find(mindist(track1) > centdist(mincenter(track1),j));
            track1 = track1(track2);
            if isempty(track1) continue; end
           
            % calculate exact distances to center j
            track4 = find(lower(track1,j) < mindist(track1));
            if isempty(track4) continue; end
            track5 = track1(track4);
            jdist = calcdist(data(track5,:),centers(j,:));
            computed = computed + size(track5,1);
            lower(track5,j) = jdist;
                    
            % find which points really are assigned to center j
            track2 = find(jdist < mindist(track5));
            track3 = track5(track2);
            mindist(track3) = jdist(track2);
            mincenter(track3) = j;
        end % for j=1:k
    end % if method
      
    oldcenters = centers;
        
% M step: recalculate the means for each cluster
% if a cluster is empty, its mean is left unchanged
% we minimize computations for clusters with little changed membership
    
    diff = find(mincenter ~= oldmincenter);
    diffj = unique([mincenter(diff);oldmincenter(diff)])';
    diffj = diffj(find(diffj > 0));
    
    if size(diff,1) < n/3 & iteration > 0
         for j = diffj
            plus = find(mincenter(diff) == j);
            minus = find(oldmincenter(diff) == j);
            oldpop = pop(j);
            pop(j) = pop(j) + size(plus,1) - size(minus,1);
            if pop(j) == 0 continue; end
            centers(j,:) = (centers(j,:)*oldpop + sum(data(diff(plus),:),1) - sum(data(diff(minus),:),1))/pop(j); 
        end
    else
        for j = diffj
            track = find(mincenter == j);
            pop(j) = size(track,1);
            if pop(j) == 0 continue; end
% it's correct to have mean(data(track,:),1) but this can make answer worse!
            centers(j,:) = mean(data(track,:),1);
        end
    end
    
    if method == 2
        for j = diffj
            offset = calcdist(centers(j,:),oldcenters(j,:));
            computed = computed + 1;
            if offset == 0 continue; end
            track = find(mincenter == j);
            mindist(track) = mindist(track) + offset;
            lower(:,j) = max(lower(:,j) - offset,0);
        end

% compute distance between each pair of centers
% modify centdist to make "find" using it faster
        recalculated = zeros(n,1);
        realdist = alldist(centers);
        centdist = 0.5*realdist + diag(Inf*ones(k,1));
        computed = computed + k + k*(k-1)/2;   
    end
    
    nchanged = size(diff,1) + skipestep;
    iteration = iteration+1;
    skipestep = 0;
    oldmincenter = mincenter;

%   difference = max(max(abs(oldcenters - centers)));
%   [iteration toc nchanged computed size(diffj,2)]
    %[iteration toc nchanged computed];
    total = total + computed;
end % while nchanged > 0

udist = calcdist(data,centers(mincenter,:));
quality = mean(udist);
q2 = mean(udist.^2);
%[iteration toc quality q2 total];

end

function distances = calcdist(data,center)
%  input: vector of data points, single center or multiple centers
% output: vector of distances

[n,dim] = size(data);
[n2,dim2] = size(center);

% Using repmat is slower than using ones(n,1)
%   delta = data - repmat(center,n,1);
%   delta = data - center(ones(n,1),:);
% The following is fastest: not duplicating the center at all

if n2 == 1
    distances = sum(data.^2, 2) - 2*data*center' + center*center';
elseif n2 == n
    distances = sum( (data - center).^2 ,2);
else
    error('bad number of centers');
end

% Euclidean 2-norm distance:
distances = sqrt(distances);

% Inf-norm distance:
% distances = max(abs(distances),[],2);
end


%%

function [centers, mincenter, mindist, lower, computed] = anchors(firstcenter,k,data)
% choose k centers by the furthest-first method

[n,dim] = size(data);
centers = zeros(k,dim);
lower = zeros(n,k);
mindist = Inf*ones(n,1);
mincenter = ones(n,1);
computed = 0;
centdist = zeros(k,k);

for j = 1:k
    if j == 1
        newcenter = firstcenter;
    else
        [maxradius,i] = max(mindist);
        newcenter = data(i,:);
    end

    centers(j,:) = newcenter;
    centdist(1:j-1,j) = calcdist(centers(1:j-1,:),newcenter);
    centdist(j,1:j-1) = centdist(1:j-1,j)';
    computed = computed + j-1;
    
    inplay = find(mindist > centdist(mincenter,j)/2);
    newdist = calcdist(data(inplay,:),newcenter);
    computed = computed + size(inplay,1);
    lower(inplay,j) = newdist;
        
%    other = find(mindist <= centdist(mincenter,j)/2);
%    if ~isempty(other)
%        lower(other,j) = centdist(mincenter(other),j) - mindist(other);
%    end    
        
    move = find(newdist < mindist(inplay));
    shift = inplay(move);
    mincenter(shift) = j;
    mindist(shift) = newdist(move);
end

%udist = calcdist(data,centers(mincenter,:));
%quality = mean(udist);
%q2 = mean(udist.^2);
%[k toc quality q2 computed]
%toc
end


function centdist = alldist(centers)
% output: matrix of all pairwise distances
% input: data points (centers)

k = size(centers,1);
centdist = zeros(k,k);
for j = 1:k
    centdist(1:j-1,j) = calcdist(centers(1:j-1,:),centers(j,:));
end
centdist = centdist+centdist';
end