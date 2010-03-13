function svmlightWriteData(X, y, fname, yformat)
% Write data in svm_light format
% X is nexamples-by-nfeatures
% y is nexamples-by-1 and contains only {-1,0,1}
% fname is the file name to which the data will be written.
    
    [n, d] = size(X); 
    data = zeros(n, 2*d+1);
    data(:, 1) = y;
    data(:, 2:2:end) = repmat(1:d, n, 1); 
    data(:, 3:2:end) = X;
    format = repmat([yformat, repmat(' %d:%f', 1, d), '\n'], 1, n);
    fid = fopen(fname, 'w');
    data = data';
    fprintf(fid, format, data(:)); 
    fclose(fid);
    
   
end