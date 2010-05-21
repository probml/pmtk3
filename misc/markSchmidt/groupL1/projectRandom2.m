function [p] = projectRandom2(c,lambda)
% Finds solution p of:
%   min_p ||c - p||_2
%    s.t. |p| <= lambda
%
% Assumes all elements of c are positive (this version handles ties)
%
% This version operates in-place
% (slower in Matlab, but faster in C)

nVars = length(c);

if sum(c) <= lambda
    p = c;
    return;
end

mink = 1;
p = c(c>0);
nVars = length(p);
maxk = nVars;
offset = 0;
while 1
    
    % Chose a (nearly) random element of the partition
    % (we take the median of 3 random elements to help 
    %   protect us against choosing a bad pivot)
    cand1 = p(mink-1+ceil(rand*(maxk-mink+1)));
    cand2 = p(mink-1+ceil(rand*(maxk-mink+1)));
    cand3 = p(mink-1+ceil(rand*(maxk-mink+1)));
    p_k = median([cand1 cand2 cand3]); 
    
    % Partition Elements in range {mink:maxk} around p_k
    lowerLen = 0;
    middleLen = 0;
    for i = mink:maxk
       if p(i) > p_k
           p([i mink+lowerLen]) = p([mink+lowerLen i]);
           lowerLen = lowerLen+1;
           if p(i) == p_k
               p([i mink+middleLen]) = p([mink+middleLen i]);
           end
           middleLen = middleLen+1;
       elseif p(i) == p_k
           p([i mink+middleLen]) = p([mink+middleLen i]);
           middleLen = middleLen+1;
       end
    end
    middleLen = middleLen-lowerLen;
    upperLen = maxk-mink-lowerLen-middleLen+1;

    % Find out what k value this element corresponds to
    k = lowerLen+middleLen+mink-1;
    
    % Compute running sum from 1 up to k-1
    s1 = offset + sum(p(mink:mink+lowerLen-1)) + p_k*(middleLen-1);

    % Compute Soft-Threshold up to k
    LHS = s1 - (k-1)*p_k;

    if k < nVars
        % Find element k+1
        if upperLen==0
            p_kP1 = p_maxkP1;
        else
            p_kP1 = max(p(mink+lowerLen+middleLen:maxk));
        end
    else
        % We pad the end of the array with an extra '0' element
        p_kP1 = 0;
    end

    % Compute Soft-Threshold up to k+1
    s2 = s1 + p_k;
    RHS = s2 - k*p_kP1;

    if lambda >= LHS && (lambda < RHS || upperLen == 0)
        break;
    end

    if lambda < LHS % Decrease maxk
        maxk = k-middleLen;
        p_maxkP1 = p_k;
    else % lambda > RHS, Increase mink
        mink = k+1;
        offset = s2;
    end
end

tau = p_k - (lambda - LHS)/k;
p = max(c-tau,0);