%% Inferring entities from phrases

% This file is from pmtk3.googlecode.com

function entityDgm2()


model = mkModel();

test_phrases = {};
test_phrases{end+1} = {'michael jordan'};
test_phrases{end+1} = {'michael jordan', 'and', 'his', 'friend'};
test_phrases{end+1} = {'michael jordan', 'statistics', 'professor'};


for test_ndx = 1:numel(test_phrases)
  phrases = test_phrases{test_ndx};
  tokens = tokenize(model.dictionary, phrases);
  model.dgm = mkDgm(model, numel(tokens));
  fprintf('text: '); fprintf('%s, ', phrases{:}); fprintf('\n');
  probESenum = inferEnum(model, tokens);
  fprintf('bel enum\n'); displayBel(probESenum);
  probESdgm = inferDgm(model, tokens);
  fprintf('bel dgm\n'); displayBel(probESdgm);
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

model = structure(dictionary, entity_names, entity_prior, ...
  word_prob_alias, word_prob_context, ...
  word_prob_background, prob_background_entity,...
  prob_alias);

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


function probs = mkJointEntityPrior(prior_entity)
num_entities = numel(prior_entity);
N = 2^num_entities;
probs = zeros(1,N);
for i=1:N
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  entities = find(bits);
  p = prod(prior_entity(entities));
  probs(i) = p;
end
end

function dgm = mkDgm(model, num_tokens)
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
[num_words num_entities] = size(model.word_prob_alias);
znode = zeros(1, num_tokens);
ynode = zeros(1, num_tokens);
anode = zeros(1, num_tokens);
node_counter = 1;
eset_node = node_counter; node_counter = node_counter + 1;
for e=1:num_tokens
  znode(e) = node_counter; node_counter = node_counter + 1;
end
for e=1:num_tokens
  anode(e) = node_counter; node_counter = node_counter + 1;
end
for e=1:num_tokens
  ynode(e) = node_counter; node_counter = node_counter + 1;
end
nodes = structure(eset_node, znode, anode, ynode);
num_nodes = node_counter - 1;

G = zeros(num_nodes, num_nodes);
for i=1:num_tokens
  G(eset_node, znode(i)) = 1;
  G(znode(i), ynode(i)) = 1;
  G(anode(i), ynode(i)) = 1;
end

CPD_pointers = zeros(1, num_nodes);
CPD_counter = 1;

T = mkJointEntityPrior(model.entity_prior);
CPD_eset = tabularCpdCreate(T);
CPD_pointers(eset_node) = CPD_counter;
CPD_counter = CPD_counter + 1;

% prob z given eset
% z=0 wp prob_background_entity
% otherwise we choose an entity uar from eset
no_entity = num_entities+1;
num_esets = 2^num_entities;
T = zeros(num_esets, num_entities+1);
for i=1:num_esets
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  entities = find(bits);
  prob_entity = (1-model.prob_background_entity)*(1/numel(entities));
  T(i, entities) = prob_entity;
  T(i, no_entity) = model.prob_background_entity;
end
CPD_znode  = tabularCpdCreate(T);
for i=1:num_tokens
  CPD_pointers(znode(i)) = CPD_counter;
end
CPD_counter = CPD_counter + 1;

% prob alias
T = [1-model.prob_alias model.prob_alias];
CPD_anode = tabularCpdCreate(T);
for i=1:num_tokens
  CPD_pointers(anode(i)) = CPD_counter;
end
CPD_counter = CPD_counter + 1;


% prob word given z,a
% znode has lower topological order than anode so must come first
% in dimensions
T = zeros(num_entities+1, 2, num_words);
for e=1:num_entities
  T(e, 1, :) = model.word_prob_context(:, e)';
  T(e, 2, :) = model.word_prob_alias(:, e)';
end
e = num_entities+1; % background
T(e, 1, :) = model.word_prob_background;
T(e, 2, :) = model.word_prob_background;
CPD_ynode = tabularCpdCreate(T);
for i=1:num_tokens
  CPD_pointers(ynode(i)) = CPD_counter;
end
CPD_counter = CPD_counter + 1;


CPDs = {CPD_eset, CPD_znode, CPD_anode, CPD_ynode};

dgm = dgmCreate(G, CPDs, 'CPDpointers', CPD_pointers);

dgm.nodes = nodes; 

end

%model = structure(dictionary, entity_names, entity_prior, ...
%  word_prob_alias, word_prob_context, ...
%  word_prob_background, prob_background_entity,...
%  prob_alias);


function p = likTokenGivenEset(model, token, eset)
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
p = p0*lik0 + sum(pe*like);
end

function p= likAllTokensGivenEset(model, tokens, eset)
p = 1;
for i=1:numel(tokens)
  p = p * likTokenGivenEset(model, tokens(i), eset);
end
end

function probs = inferEnum(model, tokens)
num_entities = numel(model.entity_names);
N = 2^num_entities;
probs = zeros(1,N);
prior = mkJointEntityPrior(model.entity_prior);
for i=1:N
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  entities = find(bits);
  probs(i) = prior(i) * likAllTokensGivenEset(model, tokens, entities);
end
probs = normalize(probs);
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


function probES = inferDgm(model, tokens)
dgm = model.dgm;
num_entities = numel(model.entity_names);
num_nodes = size(dgm.G, 1);

% get node names
nodes = dgm.nodes;
eset_node = nodes.eset_node;
ynode = nodes.ynode; znode = nodes.znode;

% do inference
ev = sparsevec(ynode, tokens, num_nodes);
[bels, logZ] = dgmInferNodes(dgm, 'clamped', ev);

probES = bels{eset_node}.T(:)';

fprintf('prob z\n');
num_tokens = numel(tokens);
for i=1:num_tokens
  probs = bels{znode(i)}.T(:);
  fprintf('%5.3f, ', probs); fprintf('\n');
end

%{
fprintf('prob a\n');
probs = [];
for i=1:num_tokens
  probs =  [probs bels{anode(i)}.T(2)];
end
fprintf('%5.3f, ', probs); fprintf('\n');
%}

end
