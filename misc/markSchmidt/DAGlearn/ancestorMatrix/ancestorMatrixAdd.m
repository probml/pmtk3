function [A] = ancestorMatrixAdd(A,i,j)    
    % i can now get to j
    A(i,j) = 1;
    
    % i can now get to children of j
    A(i,A(j,:)==1) = 1;
    
    
    parents_i = find(A(:,i));
    for parent = parents_i
        % parents of i can now get to j
        A(parent,j) = 1;
        
        % parents of i can now get to children of j
        A(parent,A(j,:)==1) = 1;
    end
end