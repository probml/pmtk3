%% Inferring entities from phrases

% This file is from pmtk3.googlecode.com

function entityDgm()

dictionary = {'michael jordan', 'air jordan', 'michael i jordan', ...
  'famous', 'basketball', 'star', 'professor', ...
  'statistics', 'the', 'my', 'friend', 'big', 'and', 'his', 'math'};

model = mkModel(dictionary);

test_phrases = {};
test_phrases{end+1} = {'michael jordan'};
test_phrases{end+1} = {'michael jordan', 'and', 'his', 'friend'};
test_phrases{end+1} = {'michael jordan', 'statistics', 'professor'};


for test_ndx = 1:numel(test_phrases)
  phrases = test_phrases{test_ndx};
  tokens = tokenize(dictionary, phrases);
  dgm = mkDgm(model, numel(tokens));
  fprintf('text: '); fprintf('%s, ', phrases{:}); fprintf('\n');
  infer(dgm, tokens);
  fprintf('\n\n');
end

end

function model = mkModel(dictionary)

num_words = length(dictionary);

prob_background_entity = 0.5;
num_entities = 2;
entity_names = {'MJbb', 'MJprof'};

entity_prior = [0.1, 0.1];

aliases = cell(1, num_entities);
prob_alias = 0.25; % as opposed to using context word
aliases{1} = {'michael jordan', 'air jordan'};
aliases{2} = {'michael jordan', 'michael i jordan'};
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

prob = ones(1, num_words);
all_aliases = cat(2, aliases{1}, aliases{2});
for i=1:numel(all_aliases)
  word = all_aliases{i};
  token =  find(findString(word, dictionary));
  prob(token) = 0.1; % aliases less likely to come from background
end
word_prob_background = normalize(prob);

model = structure(entity_names, entity_prior, ...
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

function dgm = mkDgm(model, num_tokens)
[num_words num_entities] = size(model.word_prob_alias);
entity_node = zeros(1, num_entities);
znode = zeros(1, num_tokens);
ynode = zeros(1, num_tokens);
anode = zeros(1, num_tokens);
node_counter = 1;
for e=1:num_entities
  entity_node(e) = node_counter; node_counter = node_counter + 1;
end
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
nodes = structure(entity_node, eset_node, znode, anode, ynode);
num_nodes = node_counter - 1;

G = zeros(num_nodes, num_nodes);
for e=1:num_entities
  G(entity_node(e), eset_node) = 1;
end
for i=1:num_tokens
  G(eset_node, znode(i)) = 1;
  G(znode(i), ynode(i)) = 1;
  G(anode(i), ynode(i)) = 1;
end

CPD_pointers = zeros(1, num_nodes);
CPD_entity = cell(1, num_entities);
CPD_counter = 1;
for e=1:num_entities
  prob = model.entity_prior(e);
  CPD_entity{e} = tabularCpdCreate([1-prob prob]);
  CPD_pointers(entity_node(e)) = CPD_counter;
  CPD_counter = CPD_counter + 1;
end


% determinisitc CPD for eset given bit vector
num_esets =  2^num_entities; % num hypotheses
prob_Eset_given_entities = reshape(eye(num_esets, num_esets),...
  [2*ones(1, num_entities) num_esets]);
CPD_eset = tabularCpdCreate(prob_Eset_given_entities);
CPD_pointers(eset_node) = CPD_counter;
CPD_counter = CPD_counter + 1;

% prob z given eset
no_entity = num_entities+1;
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


CPDs = {CPD_entity{:}, CPD_eset, CPD_znode, CPD_anode, CPD_ynode};

dgm = dgmCreate(G, CPDs, 'CPDpointers', CPD_pointers);

dgm.nodes = nodes; 

end



function infer(dgm, tokens)
num_nodes = size(dgm.G, 1);
nodes = dgm.nodes;
entity_node = nodes.entity_node; eset_node = nodes.eset_node;
ynode = nodes.ynode; znode = nodes.znode;
anode = nodes.anode;
ev = sparsevec(ynode, tokens, num_nodes);
[bels, logZ] = dgmInferNodes(dgm, 'clamped', ev);

num_entities = numel(entity_node);
fprintf('marginal prob entities\n');
probs = [];
for e=1:num_entities
  probs =  [probs bels{entity_node(e)}.T(2)];
end
fprintf('%5.3f, ', probs); fprintf('\n');

probES = bels{eset_node}.T;
N = 2^num_entities;
fprintf('prob sets of entities\n')
for i=1:N
  bits = ind2subv(2*ones(1, num_entities), i)-1;
  entities = find(bits);
  str = sprintf('%d ', entities);
  fprintf('%8.5f %s\n', probES(i), str);
end

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
