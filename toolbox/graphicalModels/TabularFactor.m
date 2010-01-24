classdef TabularFactor
   % tabular (multi-dimensional array) factor/potential
   
   properties
      T; % multi-dimensional array
      domain;
      sizes;
   end
   
   %% main methods
   methods
      function m = TabularFactor(T, domain)
         if nargin < 1, T = []; end
         if nargin < 2, domain = 1:ndimsPMTK(T); end
         m.T = T;
         m.domain = domain;
         if(isvector(T) && numel(domain) > 1)
            m.sizes = size(T);
         else
            m.sizes = sizePMTK(T);
         end
      end
      
      function p = pmf(obj)
         % p(j,k,...) = p(X=(j,k,...)), multidim array
         p = obj.T;
      end
      
      
      function d = ndimensions(T)
         d = length(T.domain);
      end
      
      function S = sample(T, n)
         if nargin < 2, n = 1; end
         S = ind2subv(T.sizes, sample(T.T(:), n));
      end
      
      function smallpot = marginalize(bigpot, onto, maximize)
         % smallpot = marginalizeFactor(bigpot, onto, maximize)
         if nargin < 3, maximize = 0; end
         %       ns = zeros(1, max(bigpot.domain));
         %       ns(bigpot.domain) = bigpot.sizes;
         smallT = marg_table(bigpot.T, bigpot.domain, bigpot.sizes, onto, maximize);
         smallpot = TabularFactor(smallT, onto);
      end
      
      function Tbig = multiplyBy(Tbig, Tsmall)
         % Tsmall's domain must be a subset of Tbig's domain.
         
         Ts = extend_domain_table(Tsmall.T, Tsmall.domain, Tsmall.sizes, Tbig.domain, Tbig.sizes);
         Tbig.T = Tbig.T.*Ts;
         
         %% bsxfun version is slower!
         %         bigdom   = Tbig.domain;
         %         smalldom = Tsmall.domain;
         %         map      = lookupIndices(smalldom,bigdom);
         %         sz       = ones(1, max(2,numel(bigdom)));
         %         sz(map)  = Tsmall.sizes;
         %         Tbig.T   = bsxfun(@times,Tbig.T, reshape(Tsmall.T, sz)); % avoids call to repmat
         %%
      end
      
      function Tbig = divideBy(Tbig, Tsmall)
         % Tsmall's domain must be a subset of Tbig's domain.
         Ts = extend_domain_table(Tsmall.T, Tsmall.domain, Tsmall.sizes, Tbig.domain, Tbig.sizes);
         % Replace 0s by 1s before dividing. This is valid, Ts(i)=0 iff Tbig(i)=0.
         Ts = Ts + (Ts==0);
         Tbig.T = Tbig.T ./ Ts;
      end
      
      
      
      function [Tfac, Z] = normalizeFactor(Tfac)
         [Tfac.T, Z] = normalize(Tfac.T);
      end
      
      function Tsmall = slice(Tbig, visVars, visValues)
         % Return Tsmall(hnodes) = Tbig(visNodes=visValues, hnodes=:)
         % visVars are global names, which are looked up in the domain
         if isempty(visVars), Tsmall = Tbig; return; end
         d = ndimensions(Tbig);
         Vndx = lookupIndices(visVars, Tbig.domain);
         ndx = mk_multi_index(d, Vndx, visValues);
         Tsmall = squeeze(Tbig.T(ndx{:}));
         H = setdiffPMTK(Tbig.domain, visVars);
         Tsmall = TabularFactor(Tsmall, H);
      end
      
      function [TQ] = conditional(T, queryVars, visVars, visValues)
         T = slice(T, visVars, visValues);
         T = normalizeFactor(T);
         TQ = marginalize(T, queryVars);
      end
      
      function p = extract(T)
         p = T.T;
      end
      
      function cellArray = copy(obj,varargin)
         cellArray = num2cell(repmat(obj,varargin{:}));
      end
      
      
   end % methods

  methods(Static = true)
    
      function T = multiplyFactors(facs)
          % T = multiplyFactors({fac1, fac2, ...})     
          facs = facs(cellfun(@(x)~isequal(pmf(x),1),facs));                    % ignore idempotent factors
          N = numel(facs);
          dom = [];
          for i=1:N
              dom = [dom facs{i}.domain];
          end
          dom = unique(dom);
          ns = zeros(1, max(dom));
          for i=1:N
              Ti = facs{i};
              ns(Ti.domain) = Ti.sizes;
          end
          sz = prod(ns(dom));
          if sz>100000
              fprintf('creating tabular factor with %d entries\n', sz);
          end
          T = TabularFactor(onesPMTK(ns(dom)), dom);
          for i=1:N
              Ti = facs{i};
              T = multiplyBy(T, Ti);
          end
      end
    
    function joint = testSprinkler()
      % water sprinkeler BN
      %   C
      %  / \
      % v  v
      % S  R
      %  \/
      %  v
      %  W
      % Specify the conditional probability tables as cell arrays
      % The left-most index toggles fastest, so entries are stored in this order:
      % (1,1,1), (2,1,1), (1,2,1), (2,2,1), etc.
      C = 1; S = 2; R = 3; W = 4;
      CPD{C} = reshape([0.5 0.5], 2, 1);
      CPD{R} = reshape([0.8 0.2 0.2 0.8], 2, 2);
      CPD{S} = reshape([0.5 0.9 0.5 0.1], 2, 2);
      CPD{W} = reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], 2, 2, 2);
      % naive method
      joint = zeros(2,2,2,2);
      for c=1:2
        for r=1:2
          for s=1:2
            for w=1:2
              joint(c,s,r,w) = CPD{C}(c) * CPD{S}(c,s) * CPD{R}(c,r) * CPD{W}(s,r,w);
            end
          end
        end
      end

      % vectorized method
      joint2 = repmat(reshape(CPD{C}, [2 1 1 1]), [1 2 2 2]) .* ...
        repmat(reshape(CPD{S}, [2 2 1 1]), [1 1 2 2]) .* ...
        repmat(reshape(CPD{R}, [2 1 2 1]), [1 2 1 2]) .* ...
        repmat(reshape(CPD{W}, [1 2 2 2]), [2 1 1 1]);
      assert(approxeq(joint, joint2));
      
      % using factors
      fac{C} = TabularFactor(CPD{C}, [C]);
      fac{R} = TabularFactor(CPD{R}, [C R]);
      fac{S} = TabularFactor(CPD{S}, [C S]);
      fac{W} = TabularFactor(CPD{W}, [S R W]);
      J = TabularFactor.multiplyFactors(fac);
      joint3 = J.T;
      assert(approxeq(joint, joint3));
    end
    
  end
    

end

function smallT = marg_table(bigT, bigdom, bigsz, onto, maximize)
    % MARG_TABLE Marginalize a table
    % smallT = marg_table(bigT, bigdom, bigsz, onto, maximize)
    
    if nargin < 5, maximize = 0; end
    
    smallT = reshapePMTK(bigT, bigsz);        % make sure it is a multi-dim array
    sum_over = setdiffPMTK(bigdom, onto);
    if isempty(sum_over)
        smallT = bigT; return;
    end
    ndx = lookupIndices(sum_over, bigdom);
    if maximize
        for i=1:length(ndx)
            smallT = max(smallT, [], ndx(i));
        end
    else
        for i=1:length(ndx)
            smallT = sum(smallT, ndx(i));
        end
    end
    ns = zeros(1, max(bigdom));
    ns(bigdom) = bigsz;
    smallT = squeeze(smallT);             % remove all dimensions of size 1
    smallT = reshapePMTK(smallT, ns(onto)); % put back relevant dims of size 1
end

function B = extend_domain_table(A, smalldom, smallsz, bigdom, bigsz)
% EXTEND_DOMAIN_TABLE Expand an array so it has the desired size.
% B = extend_domain_table(A, smalldom, smallsz, bigdom, bigsz)
%
% A is the array with domain smalldom and sizes smallsz.
% bigdom is the desired domain, with sizes bigsz.
%
% Example:
% smalldom = [1 3], smallsz = [2 4], bigdom = [1 2 3 4], bigsz = [2 1 4 5],
% so B(i,j,k,l) = A(i,k) for i in 1:2, j in 1:1, k in 1:4, l in 1:5

if isequal(size(A), [1 1]) % a scalar
  B = A; % * onesPMTK(bigsz);
  return;
end

%map = find_equiv_posns(smalldom, bigdom);
map = lookupIndices(smalldom, bigdom);
sz = ones(1, length(bigdom));
sz(map) = smallsz;
B = reshapePMTK(A, sz); % add dimensions for the stuff not in A
sz = bigsz;
sz(map) = 1; % don't replicate along A's dimensions
B = repmatPMTK(B, sz(:)');
end


