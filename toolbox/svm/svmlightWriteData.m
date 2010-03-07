function svmWriteData(X, y, fname)
% Write data in svm_light format
% X is nexamples-by-nfeatures
% y is nexamples-by-1 and contains only {-1,0,1}
% fname is the file name to which the data will be written.
    
    fid = fopen(fname,'w+');
    ylabels = num2cell(y);
    ylabels(y == -1) = {'-1'};
    ylabels(y ==  1) = {'+1'};
    ylabels(y ==  0) = {'0'};
    for i=1:size(X,1)
        fprintf(fid,'%s ',ylabels{i});
        for j=1:size(X,2)
            fprintf(fid,'%d:%f ', j, X(i, j));
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end