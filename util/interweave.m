function C = interweave(A,B)
% If A, B are two cell arrays of length N1, N2, C is a cell array of length
% N1 + N2 where where C(1) = A(1), C(2) = B(1), C(3) = A(2), C(4) = B(2), ... etc
% Note, C is always a row vector. If one cell array is longer than the 
% other the remaining elements of the longer cell array are added to the
% end of C. A and B are first converted to column vectors. 

    A = A(:); B = B(:);
    C = cell(length(A)+length(B),1);
    counter = 1;
    while true
       if ~isempty(A)
          C(counter) = A(1); A(1) = [];
          counter = counter + 1;
       end
       if ~isempty(B)
           C(counter) = B(1); B(1) = [];
           counter = counter + 1;
       end
       if isempty(A) && isempty(B)
           break;
       end
    end
    C = C';

end