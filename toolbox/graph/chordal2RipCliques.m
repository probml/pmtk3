function [re_index_cliques, cliques]= chordal2RipCliques(g, order)
% inputs: 1. g, the p x p symmetric adajacency matrix with
% respect to an original ordering v_1, ..., v_p
% 2. order, the output of check_chordal or any other
% perfect numbering permutation of the vertex indicies.
% output: 1. re_index_cliques, a cell representation containing only
% non-empty cliques, re_indexed
% so that re_index_cliques{i} is the ith non-empty clique
% in a sequence of cliques that satisfies the
% running intersection property.
% 2. cliques, a cell representation of the
% cliques of g in perfect order.
% i.e. Unlike re_index_cliques, these
% are indexed with respect to the vertices in the ordering.
% So if order(j) is a ladder vertex, the cell will contain the associated clique.
% If not, the cell will be empty.
%
% Note: If cliques{i}={2, 4, 5, 7}, then clique{i} comprises
% variables v_2, v_4, v_5 and v_7 with respect to the original
% ordering of the adjacency matrix, and not the perfect numbering.

% PMTKauthor Helen Armstrong
% PMTKurl http://www.library.unsw.edu.au/~thesis/adt-NUN/uploads/approved/adt-NUN20060901.134349/public/01front.pdf

p=size(g,1);
pa=cell(1,p);
num_pa=zeros(1,p);
%initialise the vector of number of predecessors
for i=2:p;
    v=order(i);
    pre_v=order(1:i-1);
    ns=neighbors(g, v);
    % find set of neighbours of each v=order(i)
    % turn the set into a vector (so can take intersection)
    
    pa{i}=intersect(ns, pre_v);
    % find the sets of those neighbours which precede
    % v(i) with respect to order.
    % Store answer for cliques.
    
    num_pa(i)=length(pa{i});
    
    % get cardinality for ladder test. note that the ith element of num_pa
    % corresponds to the number of pre-nbs of the ith vertex in order; i.e
    % v=order(i), and NOT v=i. We need to keep variables ordered as per the
    % mcs ordering, the vector called order.
end;
ladder=zeros(1,p);
for i=1:p;
    if i==p | num_pa(i) >= num_pa(i+1);
        %if i=p or cardinality of pa decreasing with i
        %then the vertex v=order(i) is a ladder vertex.
        ladder(i)=order(i);
        %make this v the next ladder vertex
    end;
end;
cliques=cell(size(ladder));
for i=1:p;
    if ladder(i)==0
        cliques{i}=[];
    else;
        cliques{i}=union(order(i), pa{i});
        % NOTE matlab orders union(a,b) as [min(a,b), max(a,b)]
        % regardless of relative size of a,b
    end;
end;


% get rid of empty cliques
k=length(find(ladder));
new_index=1;
re_index_cliques=cell(1,k);
for i=1:p;
    if ladder(i)~=0
        re_index_cliques{new_index}=cliques{i};
        new_index=1+new_index;
    end;
end;

% Theorem: re_index_cliques{i} are the cliques of g and clique ordering satisfies the RIP.
