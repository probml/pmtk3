%% Inferring entities from phrases

% This file is from pmtk3.googlecode.com

function entityDgm3()

% if there are 3 phrases, the DAG is as follows)
%      eset
%    /  |  \
%   v   v   v
%   z1 z2   z3
%   |   |    |
%   v   v    v
%   y1  y2   y3
%   ^    ^    ^
%   |    |    |
%   a1   a2   a3

model = mkModel();

test_phrases = {};
%test_phrases{end+1} = {'his', 'and'};
%test_phrases{end+1} = {'michael jordan'};
%test_phrases{end+1} = {'michael jordan', 'and', 'his', 'friend'};
test_phrases{end+1} = {'michael jordan', 'and', 'air jordan'};
%test_phrases{end+1} = {'michael jordan', 'statistics', 'professor'};

for test_ndx = 1:numel(test_phrases)
  phrases = test_phrases{test_ndx};
  tokens = tokenize(model.dictionary, phrases);
  fprintf('text: '); fprintf('%s, ', phrases{:}); fprintf('\n');
  
  allCands = mkAllCandidateSets(model);
  probESenum = inferEnum(model, tokens, allCands);
  fprintf('bel enum\n'); displayBel(probESenum);
  fprintf('\n\n');
  
  cands = mkCandidateSets(model, tokens);
  celldisp(cands)
  probEScand = inferEnum(model, tokens, cands);
  fprintf('bel cand\n'); displayBel(probEScand);
  fprintf('\n\n');
end

end

function model = mkModel()

dictionary = {'michael jordan', 'air jordan', 'michael i jordan', ...
  'mike', 'famous', 'basketball', 'star', 'professor', ...
  'statistics', 'the', 'my', 'friend', 'big', 'and', 'his', 'math'};

num_words = length(dictionary);

entity_names = {'MJbb', 'MJprof', 'MJother'};
num_entities = numel(entity_names);
prob_background_entity = 0.5;
entity_prior = 0.1*ones(1, num_entities);

aliases = cell(1, num_entities);
prob_alias = 0.25; % as opposed to using context word
aliases{1} = {'michael jordan', 'air jordan'};
aliases{2} = {'michael jordan', 'michael i jordan'};
aliases{3} = {'michael jordan', 'mike'};

% we assume aliases are chosen uar from set
word_prob_alias = zeros(num_words, num_entities);
for e=1:num_entities
  num_aliases = numel(aliases{e});
  prob = 1/num_aliases;
  for i=1:num_aliases
    word = aliases{e}(i);
    token = find(findString(word, dictionary));
    assert(token > 0)
    word_prob_alias(token, e) = prob;
  end
end

context_words = cell(1, num_entities);
context_words{1} = {'famous', 'basketball', 'star', 'big'};
context_words{2} = {'famous', 'professor', 'statistics', 'math'};
context_words{3} = {'friend'};
% we assume context words are chosen uar from the context set
% However, they may also be any other word in the dictionary
% with prob prov_novel_context_word
word_prob_context = zeros(num_words, num_entities);
for e=1:num_entities
  prob_context_word = 1/numel(context_words{e});
  prob_noncontext_word = 1/(num_words - numel(context_words{e}));
  prob_novel_context_word = 0.01; % like Laplace smoothing
  for w=1:num_words
    word = dictionary{w};
    in_context = any(findString(word, context_words{e}));
    if in_context
      word_prob_context(w, e) = (1-prob_novel_context_word) * prob_context_word;
    else
      word_prob_context(w, e) = (prob_novel_context_word) * prob_noncontext_word;
    end
  end
end

% we assume the background distribution chooses words uar
% except that aliases are less likely to come from the background
% (since they are proper nouns)
prob = ones(1, num_words);
all_aliases = {};
for i=1:num_entities
  all_aliases = cat(2, all_aliases, aliases{i});
end
for i=1:numel(all_aliases)
  word = all_aliases{i};
  token =  find(findString(word, dictionary));
  prob(token) = 0.1; %#ok % aliases less likely to come from background
end
word_prob_background = normalize(prob);

logprior = mkJointEntityLogPrior(entity_prior);

model = structure(dictionary, entity_names, entity_prior, ...
  word_prob_alias, word_prob_context, ...
  word_prob_background, prob_background_entity,...
  prob_alias, logprior);

end


function cands = mkAllCandidateSets(model)
num_entities = numel(model.entity_names);
N = 2^num_entities;
cands = cell(1,N);
for i=1:N
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  entities = find(bits);
  cands{i} = entities;
end
end

function cands = mkCandidateSets(model, tokens)
num_tokens = numel(tokens);
num_entities = numel(model.entity_names);
no_entity = num_entities+1;
ncands_for_token = zeros(1, num_tokens);
cands_for_token = cell(1, num_tokens); % {t}(j) sorted
for i=1:num_tokens
  t = tokens(i);
  ndx = find(model.word_prob_alias(t, :));
  if ~isempty(ndx)
    probs = model.word_prob_alias(t, ndx);
    [~, perm] = sort(probs, 'descend');
    ndx = ndx(perm);
  end
  ndx = [ndx no_entity];
  cands_for_token{i} = ndx;
  ncands_for_token(i) = numel(ndx);
end
celldisp(cands_for_token)
N = prod(ncands_for_token);
cand_bitv = [];
for k=1:N
 ndx = ind2subv(ncands_for_token, k);
 eset = [];
 for i=1:num_tokens
  c = cands_for_token{i}(ndx(i));
  if c ~= no_entity
    eset = [eset c];
  end
 end
 eset = unique(eset);
 bitv = zeros(1, num_entities);
 bitv(eset) = 1;
 cand_bitv(end+1, :) = bitv;
end % for k
cand_bitv = unique(cand_bitv, 'rows');
N = size(cand_bitv, 1);
cands = cell(1,N+1);
for i=1:N
  cands{i} = find(cand_bitv(i,:));
end
cands{N+1} = []; % empty hypothesis
end

function tokens  = tokenize(dictionary, phrases)
num_tokens = numel(phrases);
tokens = zeros(1, num_tokens);
for i=1:num_tokens
  word = phrases{i};
  t = find(findString(word, dictionary));
  assert(t > 0);
  tokens(i) = t;
end
end


function logprobs = mkJointEntityLogPrior(prior_entity)
num_entities = numel(prior_entity);
N = 2^num_entities;
logprobs = zeros(1,N);
for i=1:N
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  on = find(bits==1); off = find(bits==0);
  p = sum(log(prior_entity(on))) + sum(log(1-prior_entity(off)));
  logprobs(i) = p;
end
end



function logp = loglikTokenGivenEset(model, token, eset)
% Prob of a token given a set of entities:
% p(y|es) = p(e=0) p(y|e=0) + p(e neq 0) p(y|e neq 0, es)
% p(y | e neq 0, es) = sum_{e in es} p(e) p(y|e)
% p(y|e) = p(a=0) p(y|e,a=0) + p(a=1) p(y|e,a=1)
p0 = model.prob_background_entity;
lik0 = model.word_prob_background(token);
pe = (1-p0) / numel(eset);
like = zeros(1, numel(eset));
for ei=1:numel(eset)
  e = eset(ei);
  like(ei) = model.prob_alias * model.word_prob_alias(token, e) ...
   + (1-model.prob_alias) * model.word_prob_context(token, e);
end
logp = log(p0*lik0 + sum(pe*like));
end

function logp = loglikAllTokensGivenEset(model, tokens, eset)
logp = 0;
for i=1:numel(tokens)
  logp = logp + loglikTokenGivenEset(model, tokens(i), eset);
end
end



function logp = logprior(model, entities)
 num_entities = numel(model.entity_names);
 bitv = zeros(1, num_entities);
 bitv(entities) = 1;
 k = subv2ind(2*ones(1, num_entities), bitv+1);
 logp = model.logprior(k);
end


function probsAll = inferEnum(model, tokens, candidates)
num_entities = numel(model.entity_names);
logprobs = zeros(1, numel(candidates));
for i=1:numel(candidates);
  entities = candidates{i};
  logprobs(i) = logprior(model, entities) ...
    + loglikAllTokensGivenEset(model, tokens, entities);
end
probs = exp(logprobs - logsumexp(logprobs(:)));
% now store probs in right place
N = 2^num_entities;
probsAll = zeros(1,N); % should be sparse
for i=1:numel(candidates)
  entities = candidates{i};
  bitv = zeros(1, num_entities);
  bitv(entities) = 1;
  k = subv2ind(2*ones(1, num_entities), bitv+1);
  probsAll(k) = probs(i);
end
probsAll = normalize(probsAll);
end

function probs = marginalProbsFromSet(probES)
% probs(i) = sum_{sets s: s(i) = 1} p(s)
N = numel(probES);
num_entities = log2(N);
probs = zeros(1,num_entities);
for i=1:N
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  entities = find(bits);
  p = probES(i);
  probs(entities) = probs(entities) + p;
end
end


function displayBel(probES)
N = numel(probES);
num_entities = log2(N);
fprintf('prob sets of entities\n')
for i=1:N
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  entities = find(bits);
  str = sprintf('%d ', entities);
  fprintf('%8.5f %s\n', probES(i), str);
end

marginals = marginalProbsFromSet(probES);
fprintf('induced marginal prob entities\n');
fprintf('%5.3f, ', marginals); fprintf('\n');
end
