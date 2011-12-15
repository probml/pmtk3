%% Inferring entities from phrases

% This file is from pmtk3.googlecode.com

function entityDgm4()

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
test_phrases{end+1} = {'michael jordan', 'and', 'his', 'friend'};
%test_phrases{end+1} = {'michael jordan', 'and', 'air jordan'};
%test_phrases{end+1} = {'michael jordan', 'statistics', 'professor'};

for test_ndx = 1:numel(test_phrases)
  phrases = test_phrases{test_ndx};
  tokens = tokenize(model.dictionary, phrases);
  fprintf('text: '); fprintf('%s, ', phrases{:}); fprintf('\n');
  
  %{
  allCands = mkAllCandidateSets(model);
  probESenum = inferEnum(model, tokens, allCands);
  fprintf('bel enum\n'); displayBel(probESenum);
  fprintf('\n\n');
  %}
  
  cands = mkCandidateSets(model, tokens);
  weightedHyps = inferEnum(model, tokens, cands);
  fprintf('bel cand\n'); 
  displayBel(weightedHyps);
  keyboard
  fprintf('\n\n');
end

end

function model = mkModel()

dictionary = {'michael jordan', 'air jordan', 'michael i jordan', ...
  'mike', 'famous', 'basketball', 'star', 'professor', ...
  'statistics', 'the', 'my', 'friend', 'big', 'and', 'his', 'math',...
  'a', 'b' 'c'};

num_words = length(dictionary);

entity_names = {'MJbb', 'MJprof', 'MJother', 'a', 'b', 'c'};
num_entities = numel(entity_names);
prob_background_entity = 0.5;
entity_prior = 0.1*ones(1, num_entities);

aliases = cell(1, num_entities);
prob_alias = 0.25; % as opposed to using context word
aliases{1} = {'michael jordan', 'air jordan'};
aliases{2} = {'michael jordan', 'michael i jordan'};
aliases{3} = {'michael jordan', 'mike'};
aliases{4} = {'a', 'and'};
aliases{5} = {'b'};
aliases{6} = {'c'};

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
context_words{4} = {'mike', 'and', 'a', 'famous'};
context_words{5} = {'the'};
context_words{6} = {'math'};
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
%{
for i=1:numel(all_aliases)
  word = all_aliases{i};
  token =  find(findString(word, dictionary));
  prob(token) = 0.1; %#ok % aliases less likely to come from background
end
%}
word_prob_background = normalize(prob);


model = structure(dictionary, entity_names, entity_prior, ...
  word_prob_alias, word_prob_context, ...
  word_prob_background, prob_background_entity,...
  prob_alias, num_entities);

end



function cands = mkCandidateSets(model, tokens)
% This takes the cross product of each local candidate set.
% We should enumerate these in a more intelligent order.
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
N = prod(ncands_for_token);  
fprintf('computing %d candidate joint hypotheses\n', N);
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
cands = cell(1,N);
for i=1:N
  cands{i} = find(cand_bitv(i,:));
end
%cands{N+1} = []; % empty hypothesis
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
 on = find(bitv==1); off = find(bitv==0);
 lon  = log(model.entity_prior);
 loff = log(1-model.entity_prior);
 logp = sum(lon(on)) + sum(loff(off));
end


function weightedHyps = inferEnum(model, tokens, candidates)
N = numel(candidates);
logprobs = zeros(1, N);
esets = cell(1,N);
for i=1:numel(candidates);
  entities = candidates{i};
  logprobs(i) = logprior(model, entities) ...
    + loglikAllTokensGivenEset(model, tokens, entities);
  esets{i} = entities;
end
probs = exp(logprobs - logsumexp(logprobs(:)));
probs = probs  / sum(probs);
weightedHyps.probs = probs;
weightedHyps.esets = esets;
weightedHyps.num_entities = model.num_entities;
end


%{
function probsAll = inferEnum(model, tokens, candidates)
num_entities = numel(model.entity_names);
logprobs = zeros(1, numel(candidates));
nonzero_indices = zeros(1, numel(candidates)); 
for i=1:numel(candidates);
  entities = candidates{i};
  logprobs(i) = logprior(model, entities) ...
    + loglikAllTokensGivenEset(model, tokens, entities);
  bitv = zeros(1, num_entities);
  bitv(entities) = 1;
  k = subv2ind(2*ones(1, num_entities), bitv+1);
  nonzero_indices(i) = k;
end
probs = exp(logprobs - logsumexp(logprobs(:)));
probs = probs  / sum(probs);
probsAll = sparsevec(nonzero_indices, probs, 2^num_entities);
end
%}

function probs = marginalProbsFromSet(weightedHyps)
% probs(i) = sum_{sets s: s(i) = 1} p(s)
probs = zeros(1, weightedHyps.num_entities);
N = numel(weightedHyps.esets);
for i=1:N
  entities = weightedHyps.esets{i};
  p = weightedHyps.probs(i);
  probs(entities) = probs(entities) + p;
end
end


function displayBel(weightedHyps)
fprintf('prob sets of entities\n');
N = numel(weightedHyps.esets);
for i=1:N
  entities = weightedHyps.esets{i};
  p = weightedHyps.probs(i);
  if isempty(entities)
    str = 'empty';
  else
    str = sprintf('%d ', entities);
  end
  fprintf('%8.5f %s\n', p, str);
end
marginals = marginalProbsFromSet(weightedHyps);
fprintf('induced marginal prob entities\n');
fprintf('%5.3f, ', marginals); fprintf('\n');
end
