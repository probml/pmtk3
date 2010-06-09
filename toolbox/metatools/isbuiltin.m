function TF = isbuiltin(f)
% Return true iff the specified function is built in.
if iscell(f)
    TF = cellfun(@isbuiltin, f);
    return
end
w = which(f);
TF = ~isempty(w) && ((startswith(w, 'built-in') || (startswith(w,matlabroot()))));
end