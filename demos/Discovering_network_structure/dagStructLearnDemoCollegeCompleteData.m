%% Posterior over 5-node DAGs on Sewell-Shah college data
% Iterate through all 5 node DAG and calculate the marginal likelihood to
% determine the most likely strucutre to explain the college data.

data = importdata('sewellShahData.txt');
X = data.data(:,2:size(data.data,2)) + 1;
[N, D] = size(X);
ns = [2 4 2 2 4];
alpha = 5;

% generate all dags of size D and find out the marginal likelihood
Gs = mk_all_dags(D);
numDags = length(Gs)

margLik = zeros(numDags, 1);
for i = 1:numDags
  mat = Gs{i};
  if (any(mat(3,:)) || any(mat(:,1)) || any(mat(:,5)))
    % Do not consider graph where CP has any children and where SEX or
    % SES has any parent
    margLik(i) = -inf;
  elseif ((all(mat(1,:) == 0) && all(mat(:,1) == 0)) || ...
      (all(mat(2,:) == 0) && all(mat(:,2) == 0)) || ...
      (all(mat(5,:) == 0) && all(mat(:,5) == 0)) || ...
      (all(mat(4,:)) == 0 && all(mat(:,4) == 0)))
    % Assume SEX, IQ, SES, PE are not disconnected nodes
    margLik(i) = -inf;
  else
    margLik(i) = discreteDAGlogEv(X, Gs{i}, alpha, ns);
  end
end

[margLik, maxInd] = sort(margLik, 'descend');


%% Printing out results
for i = 1:3
  fprintf('%d most likely graph, log p(D|m) = %f:\n', i, margLik(i));
  disp(Gs{maxInd(i)});
end

