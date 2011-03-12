
function [presence, filenames] = extractPresence(D, names)

Nobjects = numel(names);
N= numel(D);
presence = zeros(N, Nobjects);
for c = 1:Nobjects
    [~, frames] = LMquery(D, 'object.name', names{c}, 'exact');
    fprintf('%d examples of %s\n', numel(frames), names{c})
    presence(frames, c) = 1;
end


filenames = cell(1,N);
for i=1:N
    filenames{i} = D(i).annotation.filename;  
end

end
