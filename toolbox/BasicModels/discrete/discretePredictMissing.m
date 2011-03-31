function pred = discretePredictMissing(model, data)
% data(n,j) is value of node j, can be NaN if missing
% pred(n,j,k) is predicted probability
% pred(n,j,v) = 1 if data(n,j)=v

% model.T(k,t)

[N D] = size(data); %#ok

nStates = model.K;
if isscalar(nStates), nStates = model.K*ones(1, D); end

% First make delta functions for observed entries
[~, pred] = dummyEncoding(data, nStates);

ndx = (pred==0);
pred(ndx) = eps; % replace zeros with epsilon
  
% Now insert the prior prob into missing entries

for d=1:D
  missing = isnan(data(:,d));
  Nmiss = sum(missing);
  prob = reshape(model.T(:,d), [1 1 nStates(d)]); % 1x1xK
  pred(missing, d, :) = repmat(prob, [Nmiss 1 1]);
end



end
