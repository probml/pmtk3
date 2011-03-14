function quantized = quantizePMTK(vars, varargin)
% Quantize continuous variables
% PMTKneedsStatsToolbox grpstats
% The main purpose of this function is to quantize continuous variables for
% the use in mutual information calculations. In Y=QUANTIZE(X), rows in X
% represent different samples, and columns represent different variables. Y
% has the same size as X, but its values are integers 1,2,.. .
%
% Several options of the form Y=QUANTIZE(X,'OPTION_NAME', OPTION_VALUE) 
% can be used to modify the default behavior.
%     - 'LEVELS':     number of quantization levels, defaults to logarithmic
%                     choice. 
%     - 'CONTINUOUS': followed by a binary vector specifying, for each
%                     column, if the variable should be quantized (1) or
%                     left unchanged (0). Default behavior is based on
%                     heuristics.
%     - 'METHOD':     either 'KMEANS', 'QUANTILE' [default], or 'UNIFORM'. 
%                     Quantile-based transformation has the advantages of
%                     stability and independence of transformation of input
%                     values.
%
% Example:
%
%  X=rand(10,1);XQ=quantizePMTK(X,'levels',2);[X XQ]
% ans =
% 
%     0.8205    2.0000
%     0.4119    1.0000
%     0.4764    1.0000
%     0.0584    1.0000
%     0.2348    1.0000
%     0.1397    1.0000
%     0.7586    2.0000
%     0.9367    2.0000
%     0.9102    2.0000
%     0.8544    2.0000
%
%PMTKauthor  Stefan Schroedl
%PMTKdate 3/16/2010
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/26981-feature-selection-based-on-interaction-information


% This file is from pmtk3.googlecode.com


optargin = size(varargin,2);
stdargin = nargin - optargin;

if (stdargin<1)
    error('at least one argument required');
end

num_vars    = size(vars,2);
num_samples = size(vars,1);

% defaults for optional arguments
type_cont = -1;
method    = 'quantiles';
nlev      = -1;


% parse optional arguments
i=1;
while (i <= optargin)
    if (strcmp(varargin{i},'continuous') && i < optargin)
        type_cont = varargin{i+1};
        if numel(type_cont) ~= num_vars
            error('wrong length of continuous type argument');
        end
        i = i + 2;
    elseif (strcmp(varargin{i},'method') && i < optargin)
        method = varargin{i+1};
        i = i + 2;
    elseif (strcmp(varargin{i},'levels') && i < optargin)
        nlev = varargin{i+1};
        i = i + 2;
    elseif (ischar(varargin{i}))
        error('unrecognized attribute: %s', varargin{i});
    else
        error('usage: quantize(vars, ''option1'', option1, ...)');
    end
end


if (nlev == -1)
    nlev = 2;
    if (num_samples >= 8)
        nlev = max(2,ceil(min(log2(num_samples),sqrt(num_samples/20))));
    end
end

if type_cont == -1
    % try to guess variable types
    type_cont=any(ceil(vars)~=vars);
    type_noncont = find(~type_cont);
    for i=1:length(type_noncont)
        distinct=length(unique(vars(:,type_noncont(i))));
        if distinct > 1*nlev
            % too many values, quantize anyway
            type_cont(type_noncont(i))=1;
        end
    end
else
    % no quantization if there are already fewer distinct values
    cidx = find(type_cont);
    for i=1:length(cidx)
        distinct=length(unique(vars(:,type_cont(cidx(i)))));
        if (distinct <= nlev)
            disp('less than nlev values');
            type_cont(cidx(i))=0;
        end
    end
end

quantized = vars;
type_cont = find(type_cont);
for i=1:length(type_cont)
    ii=type_cont(i);
    %disp(sprintf('quantizing %d/%d (%s)', i, length(HEADER), HEADER{i}));
    %eval(sprintf('tmpin=%s;', HEADER{i}));
    if (strcmp(method,'kmeans'))
        tmp=kmeans(vars(:,ii), nlev,'start','cluster','replicates',3,'emptyaction','drop','MaxIter',100000);
        % reorder indices, for convenience
        means=grpstats(vars(:,ii),tmp);
        [u,ui,uj]=unique(tmp);
        [m,mi,mj]=unique(means);
        quantized(:,ii) = mj(uj);
    elseif (strcmp(method,'quantiles'))
        qvals = (1:(nlev-1))./nlev;
        thresh = quantilePMTK(vars(:,ii),qvals);
        % remove duplicate bins
        thresh = unique(thresh);
        intv=zeros(length(vars(:,ii)),1);
        for j = 1:length(thresh)
            idx=(intv==0) & vars(:,ii) <= thresh(j);
            intv(idx)=j;
        end
        intv(intv==0)=(length(thresh)+1);
        quantized(:,ii)=intv;
    elseif (strcmp(method,'uniform'))
        m0 = min(vars(:,ii));
        q=(max(vars(:,ii)) -m0)/(nlev - 1);
        tmp = ceil((vars(:,ii)-m0)/q);
        % remove empty bins
        [u,ui,uj] = unique(tmp);
        quantized(:,ii) = uj;
    else
        error('unknown quantization method: %s', method);
    end
end
