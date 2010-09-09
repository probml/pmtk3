function [biclusterRows, biclusterCols, rowPostProb, colPostProb, traceRow, traceCol] = biclusteringGibbs(data, varargin)
% Performs biclustering using Gibbs Sampling. 
% Reference:
%@misc{sheng2003biclustering,
%  title={{Biclustering microarray data by Gibbs sampling}},
%  author={Sheng, Q. and Moreau, Y. and De Moor, B.},
%  journal={Bioinformatics},
%  volume={19},
%  number={90002},
%  pages={196--205},
%  year={2003},
%  publisher={Oxford Univ Press}
%}
%PMTKauthor Cody Severinski

% This file is from pmtk3.googlecode.com


[allRowThres, allColThres, nSamples, nBurnin, nRestarts, plot, verbose, trace, alpha, xiRow, xiCol, beta] = process_options(varargin, ...
      'allRowThres', [], ...
      'allColThres', [], ...
      'nSamples', 500, ...
      'nBurnin', 50, ...
      'nRestarts', 1, ...
      'plot', true, ...
      'verbose', true, ...
      'trace', false, ...
      'alpha', 1, ...
      'xiRow', normalize(ones(1,2)), ...
      'xiCol', normalize(ones(1,2)), ...
      'beta', []);
  
  [nRow, nCol] = size(data);
  data = canonizeLabels(data);
  nLevels = max(data(:));

  if(isempty(beta))
    beta = ones(nLevels,1);
  end
  
  done = false;
  restart = 1;
  biclustIdx = 1;
  activeRow = 1:nRow; activeCol = 1:nCol;


  fprintf('\nStarting Gibbs sampler on data matrix \n')

  while(~done)

  if(verbose), fprintf('Bicluster search # %d, restart %d / %d \n', biclustIdx, restart, nRestarts); end
    maskedRow = setdiff(1:nRow, activeRow); maskedCol = setdiff(1:nCol, activeCol);
    currRow = zeros(1, nRow); currCol = zeros(1, nCol);
    currRow(maskedRow) = NaN; currCol(maskedCol) = NaN;
    currRow(activeRow) = unidrndPMTK(2,1,length(activeRow)) - 1; currCol(activeCol) = unidrndPMTK(2,1,length(activeCol)) - 1;
    % Error: we do not want the initialization to affect the counts
    %rowCount = currRow; colCount = currCol;
    rowCount = zeros(1, nRow); colCount = zeros(1, nCol);

    if(trace)
      traceRow{biclustIdx} = zeros(nRow, nSamples);
      traceRow{biclustIdx}(maskedRow, :) = NaN;
      traceCol{biclustIdx} = zeros(nCol, nSamples);
      traceCol{biclustIdx}(maskedCol, :) = NaN;
    end
    
    if(verbose), fprintf('Samples collected: '), end
    for s=1:nSamples
      if(mod(s,100) == 0 && verbose), fprintf('%d... ', s), end;
      for i=activeRow
        % find the columns and rows that are 'on'
        colOn = find(currCol == 1); colOff = find(currCol == 0);
        rowOn = find(currRow == 1); rowOff = find(currRow == 0);
        otherRowOn = setdiff(rowOn, i); otherRowOff = setdiff(rowOff, i);
        thetaHatUnnorm = bsxfun(@plus,histc(data(otherRowOn, colOn), 1:nLevels, 1),beta);
        %thetaHat = normalize( thetaHatUnnorm, 1); %give normalized counts of the data in question, columnwise
        rowValues = histc(data(i,:), 1:nLevels, 1);
        logProbRowOn = sum(sum(rowValues(:,colOn).*(bsxfun(@minus,log(thetaHatUnnorm),log(sum(thetaHatUnnorm,1)))))) + log(length(otherRowOn) + xiRow(1));
    
        otherOff = data(otherRowOff(:), colOff);
        phiHat = normalize( histc(otherOff(:), 1:nLevels, 1) + alpha);
        logProbRowOff = sum(sum(rowValues(:,colOn),2).*log(phiHat)) + log(nRow - 1 - length(otherRowOn) + xiRow(2));
    
        probRow = exp(normalizeLogspace([logProbRowOn, logProbRowOff]));
    
        % if(~isfinite(probRow)), keyboard, end; % Debugging
        u = rand(1);
        if(u < probRow(1))
          currRow(i) = 1;
          if(s > nBurnin)
            rowCount(i) = rowCount(i) + 1;
            traceRow{biclustIdx}(i, s) = 1;
          end
        else
          currRow(i) = 0;
        end
      end
      
      for j=activeCol
        colOn = find(currCol > 0); colOff = find(currCol == 0);
        rowOn = find(currRow > 0); rowOff = find(currRow == 0);
        otherColOn = setdiff(colOn, j); otherColOff = setdiff(colOff, j);
    
        notBicluster = data(rowOff, otherColOff);
        histNotBi = histc(notBicluster(:), 1:nLevels);
        colBicluster = data(:,j);
        histColBi = histc(colBicluster(:), 1:nLevels);
    
        logProbColOn = sum(gammaln(histNotBi + alpha)) - gammaln(sum(histNotBi + alpha)) + sum(gammaln(histColBi + beta)) - gammaln(sum(histColBi + beta)) + log(length(otherColOn) + xiCol(1));
    
        logProbColOff = sum(gammaln(histNotBi + histColBi + alpha)) - gammaln(sum(histNotBi + histColBi + alpha)); + log(nCol - length(otherColOn) - 1 + xiCol(2));
    
        probCol = exp(normalizeLogspace([logProbColOn, logProbColOff]));
    
        % if(~isfinite(probCol)), keyboard, end; % Debugging
        u = rand(1);
        if(u < probCol(1))
          currCol(j) = 1;
          if(s > nBurnin)
            colCount(j) = colCount(j) + 1;
            traceCol{biclustIdx}(j, s) = 1;
          end
        else
          currCol(j) = 0;
        end
      end
    
    end

    rowPostProb{biclustIdx} = (rowCount + xiRow(1)) / (nSamples - nBurnin + sum(xiRow));
    colPostProb{biclustIdx} = (colCount  + xiCol(1)) / (nSamples - nBurnin + sum(xiCol));

    if(isempty(allRowThres) || isempty(allColThres))
      tempHist = figure();
      subplot(2,1,1); hist(rowPostProb{biclustIdx});
      subplot(2,1,2); hist(colPostProb{biclustIdx});
      rowThres = input(sprintf('\nSpecify row posterior probability threshold (variable rowPostProb{%d}): ', biclustIdx))
      colThres = input(sprintf('\nSpecify column posterior probability threshold (variable colPostProb{%d}): ', biclustIdx))
      fprintf('\n')
      close(tempHist);
      if(strcmpi(rowThres, 'quit') || strcmpi(colThres, 'quit'))
        done = true;
      end
    else
      rowThres = allRowThres;
      colThres = allColThres;
    end
    expRows = find(rowPostProb{biclustIdx} > rowThres);
    expRowsText = mat2str(find(rowPostProb{biclustIdx} > rowThres));
    expCols = find(colPostProb{biclustIdx} > colThres);
    expColsText = mat2str(find(colPostProb{biclustIdx} > colThres));
    found = ~(isempty(expRows) || isempty(expCols));
    
    if(plot && found)
      figure();
      colormap('gray');
      axes('Position', [0.25, 0.25, 0.7, 0.7]);
      imagesc(data);
      text(0.25+0.7/2, 0.30, 'Data Matrix');
      
      rowBar = axes('Position', [0.15, 0.25, 0.05, 0.7]);
      imagesc(colvec(rowPostProb{biclustIdx} * nLevels));
      set(rowBar, 'XTick', []); set(rowBar, 'YTick', []);

      rowDec = axes('Position', [0.05, 0.25, 0.05, 0.7]);
      imagesc(colvec(rowPostProb{biclustIdx} > rowThres));
      set(rowDec, 'XTick', []); set(rowDec, 'YTick', []);
      
      colBar = axes('Position', [0.25, 0.15, 0.7, 0.05]);
      imagesc(rowvec(colPostProb{biclustIdx} * nLevels));
      set(colBar, 'XTick', []); set(colBar, 'YTick', []);

      colDec = axes('Position', [0.25, 0.05, 0.7, 0.05]);
      imagesc(rowvec(colPostProb{biclustIdx} > colThres));
      set(colDec, 'XTick', []); set(colDec, 'YTick', []);

      annotation('textbox', [0.03, 0.07, 0.02, 0.02], 'String', 'Decision', 'LineStyle', 'none');
      annotation('textbox', [0.12, 0.20, 0.02, 0.02], 'String', 'Posterior Probability', 'LineStyle', 'none');
    end



    if(verbose && found)
      fprintf('\nExpected rows in bicluster according to threshold level (%1.2f): %s \n', rowThres, expRowsText);

      fprintf('Expected columns in bicluster according to threshold level (%1.2f): %s \n', colThres, expColsText);
    elseif(verbose && ~found)
      fprintf('\nNo bicluster found.  Either the row of column subset was empty based on the threshold levels (row = %1.2f, column = %1.2f)\n', rowThres, colThres)
    end

    if(~found)
      if(restart < nRestarts)
        restart = restart + 1;
      else
      % Set done to true, remove the useless traces (if needed)
      %if(trace && biclustIdx > 1)
        %traceRow = traceRow(1:(biclustIdx-1));
        %traceCol = traceCol(1:(biclustIdx-1));
      %end
      done = true;
      end
    else
      biclusterRows{biclustIdx} = expRows;
      biclusterCols{biclustIdx} = expCols;
      activeRow = setdiff(activeRow, expRows);
      %activeCol = setdiff(activeCol, expCols); % the algorithm does not mask columns (the 'conditions')
      biclustIdx = biclustIdx + 1;
      clear expRows expCols rowCount colCount rowThres colThres;
    end

  end

  if(trace)
    for c=1:size(traceRow)
      traceRow{c} = cumsum(traceRow{c}, 2);
      traceCol{c} = cumsum(traceCol{c}, 2);
      
      traceRow{c} = bsxfun(@rdivide, traceRow{c}, 1:nSamples);
      traceCol{c} = bsxfun(@rdivide, traceCol{c}, 1:nSamples);
    end
  end
end
